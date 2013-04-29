# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based phash storage i.e. string internement.
## Note, this does not use in-memory caching.
## If that is wanted see the cacher class.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash
package require dbutil
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::sqlite {
    superclass phash

    # # ## ### ##### ######## #############
    ## State

    variable mytable \
	sql_get	sql_setv sql_unset sql_clear \
	sql_getv sql_unsetv sql_names sql_size
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

    # get: () -> dict
    method get {} {
	DB transaction {
	    DB eval $sql_get
	}
    }

    # set: dict -> ()
    method set {dict} {
	DB transaction {
	    dict for {key value} $dict {
		DB eval $sql_setv
	    }
	}
    }

    # unset: (pattern?) -> ()
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

    # getv: (key) -> value
    method getv {key} {
	DB transaction {
	    if {![DB exists $sql_getv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB onecolumn $sql_getv
	}
    }

    # setv: (key, value) -> value
    method setv {key value} {
	DB transaction {
	    DB eval $sql_setv
	}
	return $value
    }

    # unsetv: (key) -> ()
    method unsetv {key} {
	DB transaction {
	    if {![DB exists $sql_getv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB eval $sql_unsetv
	}
    }

    # names () -> list(string)
    method names {} {
	DB transaction {
	    DB eval $sql_names
	}
    }

    # exists: string -> boolean
    method exists {key} {
	DB transaction {
	    DB exists $sql_getv
	}
    }

    # size () -> integer
    method size {} { 
	DB transaction {
	    DB eval $sql_size
	}
    }

    # clear () -> ()
    method clear {} {
	DB transaction {
	    DB eval $sql_clear
	}
    }

    # # ## ### ##### ######## #############

    method Validate {key} {
	if {[info exists mymap($key)]} return
	my Error "Expected key, got \"$key\"" \
	    BAD KEY $key
    }

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	if {![dbutil initialize-schema $fqndb reason $table {{
	    key   TEXT PRIMARY KEY,
	    value TEXT NOT NULL UNIQUE
	} {
	    {key   TEXT 0 {} 1}
	    {value TEXT 1 {} 0}
	}}]} {
	    my Error $reason BAD SCHEMA
	}

	# Generate the custom sql commands.
	my Def sql_get    { SELECT key, value FROM "<<table>>" }
	my Def sql_getv   { SELECT value      FROM "<<table>>" WHERE key = :key }
	my Def sql_names  { SELECT key        FROM "<<table>>" }
	my Def sql_size   { SELECT count(*)   FROM "<<table>>" }
	my Def sql_setv   { INSERT OR REPLACE INTO "<<table>>" VALUES (:key, :value) }
	my Def sql_clear  { DELETE            FROM "<<table>>" }
	my Def sql_unset  { DELETE            FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_unsetv { DELETE            FROM "<<table>>" WHERE key = :key }
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
package provide phash::sqlite 0
return
