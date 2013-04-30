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
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::mtime::sqlite {
    superclass phash::mtime

    # # ## ### ##### ######## #############
    ## State

    variable mytable \
	sql_clear sql_get sql_getall sql_gett sql_gettall \
	sql_gettv sql_getv sql_names sql_namesall sql_setv \
	sql_size sql_unset sql_unsetv
    # Name of the database table used for storage
    # plus the sql commands to access it.

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

    # get: pattern? --> dict
    method get {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction {
		DB eval $sql_getall
	    }
	} else {
	    DB transaction {
		DB eval $sql_get
	    }
	}
    }

    # get: pattern? --> dict
    method gett {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction {
		DB eval $sql_gettall
	    }
	} else {
	    DB transaction {
		DB eval $sql_gett
	    }
	}
    }

    # set: dict --> ()
    method set {dict} {
	set time [clock seconds]
	DB transaction {
	    dict for {key value} $dict {
		DB eval $sql_setv
	    }
	}
    }

    # unset: pattern? --> ()
    method unset {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction {
		DB eval $sql_clear
	    }
	} else {
	    DB transaction {
		DB eval $sql_unset
	    }
	}
    }

    # getv: key --> value
    method getv {key} {
	DB transaction {
	    if {![DB exists $sql_getv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB onecolumn $sql_getv
	}
    }

    # gettv: key --> value
    method gettv {key} {
	DB transaction {
	    if {![DB exists $sql_gettv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB onecolumn $sql_gettv
	}
    }

    # setv: (key, value, time) --> value
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

    # unsetv: key --> ()
    method unsetv {key} {
	DB transaction {
	    if {![DB exists $sql_getv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB eval $sql_unsetv
	}
    }

    # names: pattern? --> list(string)
    method names {{pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction {
		DB eval $sql_namesall
	    }
	} else {
	    DB transaction {
		DB eval $sql_names
	    }
	}
    }

    # exists: string --> boolean
    method exists {key} {
	DB transaction {
	    DB exists $sql_getv
	}
    }

    # size: () --> integer
    method size {} { 
	DB transaction {
	    DB eval $sql_size
	}
    }

    # clear: () --> ()
    method clear {} {
	DB transaction {
	    DB eval $sql_clear
	}
    }

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	if {![dbutil initialize-schema $fqndb reason $table {{
	    key   TEXT PRIMARY KEY,
	    mtime DATE NOT NULL,
	    value TEXT NOT NULL
	} {
	    {key   TEXT 0 {} 1}
	    {mtime DATE 1 {} 0}
	    {value TEXT 1 {} 0}
	}}]} {
	    my Error $reason BAD SCHEMA
	}

	# Generate the custom sql commands.
	my Def sql_get      { SELECT key, value FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_getall   { SELECT key, value FROM "<<table>>" }
	my Def sql_getv     { SELECT value      FROM "<<table>>" WHERE key = :key }
	my Def sql_gett     { SELECT key, strftime('%s',mtime) FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_gettall  { SELECT key, strftime('%s',mtime) FROM "<<table>>" }
	my Def sql_gettv    { SELECT strftime('%s',mtime)      FROM "<<table>>" WHERE key = :key }
	my Def sql_names    { SELECT key        FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_namesall { SELECT key        FROM "<<table>>" }
	my Def sql_size     { SELECT count(*)   FROM "<<table>>" }
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

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::mtime::sqlite 0
return
