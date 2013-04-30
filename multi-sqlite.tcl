# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based phash::multi storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::multi
package require dbutil
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::multi::sqlite {
    superclass phash::multi

    # # ## ### ##### ######## #############
    ## State

    variable mytable \
	sql_get	sql_setv sql_unset sql_clear \
	sql_getv sql_unsetv sql_names sql_size \
	sql_getall sql_namesall sql_gclear \
	sql_gget sql_ggetv sql_gnames \
	sql_gnamesall sql_gsize sql_gunset \
	sql_gunsetv
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

    method _open {doc} {
	# Nothing to do
	return
    }


    # get: pattern? --> dict
    method _get {doc {pattern *}} {
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

    # set: dict --> ()
    method _set {doc dict} {
	DB transaction {
	    dict for {key value} $dict {
		DB eval $sql_setv
	    }
	}
    }

    # unset: pattern? --> ()
    method _unset {doc {pattern *}} {
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
    method _getv {doc key} {
	DB transaction {
	    if {![DB exists $sql_getv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB onecolumn $sql_getv
	}
    }

    # setv: (key, value) --> value
    method _setv {doc key value} {
	DB transaction {
	    DB eval $sql_setv
	}
	return $value
    }

    # unsetv: key --> ()
    method _unsetv {doc key} {
	DB transaction {
	    if {![DB exists $sql_getv]} {
		my Error "Expected key, got \"$key\"" \
		    BAD KEY $key
	    }
	    DB eval $sql_unsetv
	}
    }

    # names: pattern? --> list(string)
    method _names {doc {pattern *}} {
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
    method _exists {doc key} {
	DB transaction {
	    DB exists $sql_getv
	}
    }

    # size: () --> integer
    method _size {doc} { 
	DB transaction {
	    DB eval $sql_size
	}
    }

    # clear: () --> ()
    method _clear {doc} {
	DB transaction {
	    DB eval $sql_clear
	}
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.
    #
    ## Global API for overall (document independent access).

    # get: pattern? --> (dict doc --> list (value))
    method get {{pattern *}} {
	set r {}
	DB transaction {
	    DB eval $sql_gget {
		dict lappend r $doc $value
	    }
	}
	return $r
    }

    # unset: pattern? --> ()
    method unset {{pattern *}} {
	if {$pattern eq ""} {
	    DB transaction {
		DB eval $sql_gclear
	    }
	} else {
	    DB transaction {
		DB eval $sql_gunset 
	    }
	}
	return
    }

    # getv: key --> (dict doc --> list (value))
    method getv {key} {
	set r {}
	DB transaction {
	    DB eval $sql_ggetv {
		dict lappend r $doc $value
	    }
	}
	return $r
    }

    # unsetv: key --> ()
    method unsetv {key} {
	DB transaction {
	    DB eval $sql_gunsetv
	}
	return
    }

    # names: pattern? --> list(string)
    method names {{pattern *}} {
	if {$pattern eq ""} {
	    DB transaction {
		DB eval $sql_gnamesall
	    }
	} else {
	    DB transaction {
		DB eval $sql_gnames
	    }
	}
    }

    # size: () --> integer
    method size {} {
	DB transaction {
	    DB eval $sql_gsize
	}
    }

    # clear: () --> ()
    method clear {} {
	DB transaction {
	    DB eval $sql_gclear
	}
    }

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	# -- extend init-schema to enable creation of indices on specific columns.
	if {![dbutil initialize-schema $fqndb reason $table {{
	    doc   TEXT,
	    key   TEXT,
	    value TEXT NOT NULL,
	    PRIMARY KEY (doc, key)
	} {
	    {doc   TEXT 0 {} 1}
	    {key   TEXT 0 {} 2}
	    {value TEXT 1 {} 0}
	}}]} {
	    my Error $reason BAD SCHEMA
	}

	# Generate the custom sql commands.
	# Query and manipulate partitions/documents/...
	my Def sql_get      { SELECT key, value FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_getall   { SELECT key, value FROM "<<table>>" WHERE doc = :doc }
	my Def sql_getv     { SELECT value      FROM "<<table>>" WHERE doc = :doc AND key = :key }
	my Def sql_names    { SELECT key        FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_namesall { SELECT key        FROM "<<table>>" WHERE doc = :doc }
	my Def sql_size     { SELECT count(*)   FROM "<<table>>" WHERE doc = :doc }
	my Def sql_setv     { INSERT OR REPLACE INTO "<<table>>" VALUES (:doc, :key, :value) }
	my Def sql_clear    { DELETE            FROM "<<table>>" WHERE doc = :doc }
	my Def sql_unset    { DELETE            FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_unsetv   { DELETE            FROM "<<table>>" WHERE doc = :doc AND key = :key }

	# More sql commands. Operations across partitions.
	my Def sql_gget      { SELECT doc, value FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_ggetv     { SELECT doc, value FROM "<<table>>" WHERE key = :key }
	my Def sql_gnames    { SELECT UNIQUE key FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_gnamesall { SELECT UNIQUE key FROM "<<table>>" }
	my Def sql_gsize     { SELECT count(*)   FROM (SELECT UNIQUE doc FROM "<<table>>") }
	my Def sql_gclear    { DELETE            FROM "<<table>>" }
	my Def sql_gunset    { DELETE            FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_gunsetv   { DELETE            FROM "<<table>>" WHERE key = :key }
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
package provide phash::multi::sqlite 0
return
