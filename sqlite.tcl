# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based phash storage.

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
	DB transaction {
	    DB eval $sql_size
	}
    }

    # names: ?pattern? --> list(string)
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

    # get: ?pattern? --> dict (key --> value)
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

    # getv: key --> value
    method getv {key} {
	DB transaction {
	    my Validate $key
	    DB onecolumn $sql_getv
	}
    }

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} {
	DB transaction {
	    dict for {key value} $dict {
		DB eval $sql_setv
	    }
	}
    }

    # setv: (key, value) --> value
    method setv {key value} {
	DB transaction {
	    DB eval $sql_setv
	}
	return $value
    }

    # unset: ?pattern? --> ()
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

    # unsetv: key --> ()
    method unsetv {key} {
	DB transaction {
	    my Validate $key
	    DB eval $sql_unsetv
	}
    }

    # clear: () --> ()
    method clear {} {
	DB transaction {
	    DB eval $sql_clear
	}
    }

    # # ## ### ##### ######## #############
    ## State

    variable \
	sql_get	sql_setv sql_unset sql_clear \
	sql_getv sql_unsetv sql_names sql_size \
	sql_getall sql_namesall
    # All sql commands used to access our table.

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	if {![dbutil initialize-schema $fqndb reason $table {{
	    key   TEXT PRIMARY KEY,
	    value TEXT NOT NULL
	} {
	    {key   TEXT 0 {} 1}
	    {value TEXT 1 {} 0}
	}}]} {
	    my Error $reason BAD SCHEMA
	}

	# Generate the custom sql commands.
	my Def sql_get      { SELECT key, value FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_getall   { SELECT key, value FROM "<<table>>" }
	my Def sql_getv     { SELECT value      FROM "<<table>>" WHERE key = :key }
	my Def sql_names    { SELECT key        FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_namesall { SELECT key        FROM "<<table>>" }
	my Def sql_size     { SELECT count(*)   FROM "<<table>>" }
	my Def sql_setv     { INSERT OR REPLACE INTO "<<table>>" VALUES (:key, :value) }
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
package provide phash::sqlite 0
return
