# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## sqlite based phash::multitime storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::multitime
package require dbutil
package require oo::util 1.2
package require sqlite3

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::multitime::sqlite {
    superclass phash::multitime

    # # ## ### ##### ######## #############

    classmethod setup {database table} {
	# Note that an index is set on 'key' alone also, to support
	# the cross-document searches
	dbutil setup $database $table {
	    doc   TEXT,
	    key   TEXT,
	    mtime DATE NOT NULL,
	    value TEXT NOT NULL,
	    PRIMARY KEY (doc, key)
	} {{key} {doc value}}
    }

    classmethod check {database table} {
	dbutil check $database $table {
	    {doc   TEXT 0 {} 1}
	    {key   TEXT 0 {} 2}
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

    # size: () --> integer
    method _size {doc} { 
	DB transaction {
	    DB eval $sql_size
	}
    }

    # names: ?pattern? --> list(string)
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

    # get: ?pattern? --> dict (key --> value)
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

    # value: ?pattern? --> dict (key --> value)
    method _value {doc {pattern *}} {
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

    # getv: key --> value
    method _getv {doc key} {
	DB transaction {
	    my Validate $doc $key
	    DB onecolumn $sql_getv
	}
    }

    # set: dict (key --> value) --> ()
    method _set {doc dict} {
	set time [clock seconds]
	DB transaction {
	    dict for {key value} $dict {
		DB eval $sql_setv
	    }
	}
    }

    # setv: (key, value) --> value
    method _setv {doc key value {time {}}} {
	if {[llength [info level 0]] < 6} {
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

    # unsetv: key --> ()
    method _unsetv {doc key} {
	DB transaction {
	    my Validate $doc $key
	    DB eval $sql_unsetv
	}
    }

    # clear: () --> ()
    method _clear {doc} {
	DB transaction {
	    DB eval $sql_clear
	}
    }

    # get-time: ?pattern? --> dict (key --> mtime)
    method _gettime {doc {pattern *}} {
	if {$pattern eq "*"} {
	    DB transaction { DB eval $sql_gettall }
	} else {
	    DB transaction { DB eval $sql_gett }
	}
    }

    # get-timev: key --> mtime
    method _gettimev {doc key} {
	DB transaction {
	    my Validate $doc $key
	    DB onecolumn $sql_gettv
	}
    }

    # set-timev: (key, time) --> time
    method _settimev {doc key time} {
	my Validate $doc $key
	my ValidateTime $time
	DB transaction {
	    DB eval $sql_settv
	}
	return $time
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.
    #
    ## Global API for overall (document independent access).

    # size: () --> integer
    method size {} {
	DB transaction {
	    DB eval $sql_gsize
	}
    }

    # names: ?pattern? --> list(string)
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

    # keys: ?pattern? --> list(string)
    method keys {{pattern *}} {
	if {$pattern eq ""} {
	    DB transaction {
		DB eval $sql_gkeysall
	    }
	} else {
	    DB transaction {
		DB eval $sql_gkeys
	    }
	}
    }

    # get: ?pattern? --> (dict (key --> (doc --> value)))
    method get {{pattern *}} {
	set r {}
	DB transaction {
	    DB eval $sql_gget {
		dict set r $key $doc $value
	    }
	}
	return $r
    }

    # getv: key --> (dict (doc --> value))
    method getv {key} {
	set r {}
	DB transaction {
	    DB eval $sql_ggetv {
		dict lappend r $doc $value
	    }
	}
	return $r
    }

    # unset: ?pattern? --> ()
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

    # unsetv: key --> ()
    method unsetv {key} {
	DB transaction {
	    DB eval $sql_gunsetv
	}
	return
    }

    # clear: () --> ()
    method clear {} {
	DB transaction {
	    DB eval $sql_gclear
	}
    }

    # # ## ### ##### ######## #############
    ## State

    variable \
	sql_get	sql_setv sql_unset sql_clear \
	sql_getv sql_unsetv sql_names sql_size \
	sql_getall sql_namesall sql_value \
	sql_gclear sql_gget sql_ggetv sql_gnames \
	sql_gnamesall sql_gsize sql_gunset \
	sql_gunsetv sql_gkeysall sql_gkeys \
	sql_gett sql_gettall sql_gettv sql_settv
    # The sql commands to access our database table.

    # # ## ### ##### ######## #############
    ## Internals

    method InitializeSchema {table} {
	lappend map <<table>> $table

	set fqndb [self namespace]::DB

	# -- extend init-schema to enable creation of indices on specific columns.

	if {[dbutil has $fqndb $table]} {
	    if {![[self class] check $fqndb $table]} {
		my Error $reason BAD SCHEMA
	    }
	} else {
	    [self class] setup $fqndb $table
	}

	# Generate the custom sql commands.
	# Query and manipulate partitions/documents/...
	my Def sql_value    { SELECT key, value FROM "<<table>>" WHERE doc = :doc AND value GLOB :pattern }
	my Def sql_get      { SELECT key, value FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_getall   { SELECT key, value FROM "<<table>>" WHERE doc = :doc }
	my Def sql_getv     { SELECT value      FROM "<<table>>" WHERE doc = :doc AND key = :key }
	my Def sql_names    { SELECT key        FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_namesall { SELECT key        FROM "<<table>>" WHERE doc = :doc }
	my Def sql_size     { SELECT count(*)   FROM "<<table>>" WHERE doc = :doc }
	my Def sql_setv     { INSERT OR REPLACE INTO "<<table>>" VALUES (:doc, :key, (SELECT julianday(:time, 'unixepoch')), :value) }
	my Def sql_clear    { DELETE            FROM "<<table>>" WHERE doc = :doc }
	my Def sql_unset    { DELETE            FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_unsetv   { DELETE            FROM "<<table>>" WHERE doc = :doc AND key = :key }

	my Def sql_gett     { SELECT key, strftime('%s',mtime) FROM "<<table>>" WHERE doc = :doc AND key GLOB :pattern }
	my Def sql_gettall  { SELECT key, strftime('%s',mtime) FROM "<<table>>" WHERE doc = :doc }
	my Def sql_gettv    { SELECT strftime('%s',mtime)      FROM "<<table>>" WHERE doc = :doc AND key = :key }
	my Def sql_settv    { UPDATE "<<table>>" SET mtime = (SELECT julianday(:time, 'unixepoch')) WHERE doc = :doc AND key = :key }

	# More sql commands. Operations across partitions.
	my Def sql_gget      { SELECT doc, key, value FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_ggetv     { SELECT doc, value      FROM "<<table>>" WHERE key = :key }
	my Def sql_gkeys     { SELECT DISTINCT key    FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_gkeysall  { SELECT DISTINCT key    FROM "<<table>>" }
	my Def sql_gnames    { SELECT DISTINCT doc    FROM "<<table>>" WHERE doc GLOB :pattern }
	my Def sql_gnamesall { SELECT DISTINCT doc    FROM "<<table>>" }
	my Def sql_gsize     { SELECT count(*)        FROM (SELECT DISTINCT doc FROM "<<table>>") }
	my Def sql_gclear    { DELETE                 FROM "<<table>>" }
	my Def sql_gunset    { DELETE                 FROM "<<table>>" WHERE key GLOB :pattern }
	my Def sql_gunsetv   { DELETE                 FROM "<<table>>" WHERE key = :key }
	return
    }

    method Def {var sql} {
	upvar 1 map map
	set $var [string map $map $sql]
	return
    }

    method Validate {doc key} {
	if {[DB exists $sql_getv]} return
	my Error "Expected key, got \"$key\"" \
	    BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::multitime::sqlite 0
return
