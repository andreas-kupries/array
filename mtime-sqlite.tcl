# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based phash::mtime storage i.e. string internement.
## Note, this does not use in-memory caching.
## If that is wanted see the cacher class.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::mtime
package require dbutil
package require oo::util 1.2
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::mtime::sqlite {
    superclass phash::mtime

    # # ## ### ##### ######## #############

    classmethod setup {database table} {
	dbutil setup $database $table {
	    key   TEXT PRIMARY KEY,
	    mtime DATE NOT NULL,
	    value TEXT NOT NULL
	} {{value}}
    }

    classmethod check {database table} {
	dbutil check $database $table {
	    {key   TEXT 0 {} 1}
	    {mtime DATE 1 {} 0}
	    {value TEXT 1 {} 0}
	}
    }

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {database table} {
	# Make the database available as a local command, under a
	# fixed name. No need for an instance variable and resolution.
	interp alias {} [self namespace]::DB {} $database

	my InitializeSchema $table
	return
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # # ## ### ##### ######## #############
    ### Retrieval and query operations.

    # size: () --> integer
    method size {} { 
	DB transaction { DB eval $sql_size }
    }

    # names: ?pattern? --> list(string)
    method names {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction { DB eval $sql_namesall }
	} else {
	    DB transaction { DB eval $sql_names }
	}
    }

    # exists: string --> boolean
    method exists {key} {
	DB transaction { DB exists $sql_getv }
    }

    # get: ?pattern? --> dict (key --> value)
    method get {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction { DB eval $sql_getall }
	} else {
	    DB transaction { DB eval $sql_get }
	}
    }

    # getv: key --> value
    method getv {key} {
	DB transaction {
	    my Validate $key
	    DB onecolumn $sql_getv
	}
    }

    # value: ?pattern? --> dict (key --> value)
    method value {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction {
		DB eval $sql_getall
	    }
	} else {
	    DB transaction {
		DB eval $sql_value
	    }
	}
    }

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} {
	set time [clock seconds]
	DB transaction {
	    dict for {key value} $dict {
		DB eval $sql_setv
	    }
	}
    }

    # setv: (key, value, ?time?) --> value
    method setv {key value {time {}}} {
	if {[llength [info level 0]] < 5} {
	    set time [clock seconds]
	} else {
	    my ValidateTime $time
	}

	DB transaction {
	    DB eval $sql_setv
	}
	return $value
    }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction { DB eval $sql_clear }
	} else {
	    DB transaction { DB eval $sql_unset }
	}
    }

    # unsetv: key --> ()
    method unsetv {key} {
	DB transaction {
	    my Validate $key
	    DB eval $sql_unsetv
	}
    }

    # clear: () --> ()
    method clear {} {
	DB transaction { DB eval $sql_clear }
    }

    # # ## ### ##### ######## #############
    ## Additional acessors to query and change last modified
    ## information, bulk and for individual keys.

    # get-time: ?pattern? --> dict (key --> mtime)
    method get-time {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction { DB eval $sql_gettall }
	} else {
	    DB transaction { DB eval $sql_gett }
	}
    }

    # get-timev: key --> mtime
    method get-timev {key} {
	DB transaction {
	    my Validate $key
	    DB onecolumn $sql_gettv
	}
    }

    # set-timev: (key, time) --> time
    method set-timev {key time} {
	my Validate $key
	my ValidateTime $time
	DB transaction {
	    DB eval $sql_settv
	}
	return $time
    }

    # # ## ### ##### ######## #############
    ## State

    variable \
	sql_clear sql_get sql_getall sql_gett sql_gettall \
	sql_gettv sql_getv sql_names sql_namesall sql_setv \
	sql_size sql_unset sql_unsetv sql_settv sql_value
    # Name of the database table used for storage
    # plus the sql commands to access it.

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	if {[dbutil has $fqndb $table]} {
	    if {![[self class] check $fqndb $table]} {
		my Error $reason BAD SCHEMA
	    }
	} else {
	    [self class] setup $fqndb $table
	}

	# Generate the custom sql commands.
	my Def sql_value    { SELECT key, value FROM "<<table>>" WHERE value GLOB :pattern }
	my Def sql_get      { SELECT key, value FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_getall   { SELECT key, value FROM "<<table>>" }
	my Def sql_getv     { SELECT value      FROM "<<table>>" WHERE key = :key }
	my Def sql_gett     { SELECT key, strftime('%s',mtime) FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_gettall  { SELECT key, strftime('%s',mtime) FROM "<<table>>" }
	my Def sql_gettv    { SELECT strftime('%s',mtime)      FROM "<<table>>" WHERE key = :key }
	my Def sql_names    { SELECT key        FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_namesall { SELECT key        FROM "<<table>>" }
	my Def sql_size     { SELECT count(*)   FROM "<<table>>" }
	my Def sql_settv    { UPDATE "<<table>>" SET mtime = (SELECT julianday(:time, 'unixepoch')) WHERE key = :key }
	my Def sql_setv     { INSERT OR REPLACE INTO "<<table>>" VALUES (:key, (SELECT julianday(:time, 'unixepoch')), :value) }
	my Def sql_clear    { DELETE            FROM "<<table>>" }
	my Def sql_unset    { DELETE            FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_unsetv   { DELETE            FROM "<<table>>" WHERE key = :key }
	return
    }

    method Def {var sql} {
	upvar 1 map map
	set $var [string map $map $sql]
	return
    }

    method Validate {key} {
	if {[DB exists $sql_getv]} return
	my Error "Expected key, got \"$key\"" \
	    BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::mtime::sqlite 0
return
