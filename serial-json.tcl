# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## Commands to convert 'base' arrays into json and back.
## The intermediate representation is a Tcl dictionary.

## Two external representations are supported, "simple", and
## "extended". The simple form is a json object mapping keys to
## values. The extended form contains additional information (type
## data, user identification, timestamp, and checksum) around the
## simple data.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require json
package require json::write ; # config (indented|aligned) is left to user.
package require md5 2

namespace eval ::phash::serial::json {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::serial::json::toSimple {dict} {
    return [json::write::object {*}[Process [DictSort $dict]]]
}

proc ::phash::serial::json::toExtended {dict {type {}} {user {}} {when {}}} {
    if {$type eq {}} { set type array::base }
    if {$user eq {}} { set user $::tcl_platform(user) }
    if {$when eq {}} { set when [clock seconds] }
    set when [clock format $when -format {%Y-%m-%dT%H:%M:%S}]

    set sorted [DictSort $dict]
    set check  [string tolower [md5 -hex -- $sorted]]

    return [json::write::object \
		check $check \
		data  [json::write::object {*}[Process $sorted]] \
		type  $type  \
		user  $user  \
		when  $when]
}

proc ::phash::serial::json::parseSimple {json} {
}

proc ::phash::serial::json::parseExtended {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal help.

proc ::phash::serial::json::Process {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::string $v]
    }
    return $tmp
}

proc ::phash::serial::json::DictSort {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [dict get $dict $k]
    }
    return $tmp
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::serial::json {
    namespace export \
	toSimple    toExtended \
	parseSimple parseExtended
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::serial::json 0
return
