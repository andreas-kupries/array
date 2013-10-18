# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

# @@ Meta Begin
# Package phash::multitime::serial::json-extended 0
# Meta author      ?
# Meta category    ?
# Meta description ?
# Meta location    http:/core.tcl.tk/akupries/array
# Meta platform    tcl
# Meta require     ?
# Meta subject     ?
# Meta summary     ?
# @@ Meta End

## Commands to convert 'multitime' arrays into json and back.
## The intermediate representation is a Tcl dictionary.
## This package generates an 'extended' representation (compared to
## 'json-simple'). The form contains additional information, namely
## type data, user identification, timestamp, and checksum around the
## simple data.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require json
package require json::write ; # config (indented|aligned) is left to user.
package require md5 2

namespace eval ::phash::multitime::serial::json-extended {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::multitime::serial::json-extended::generate {dict {type {}} {user {}} {when {}}} {
    # dict (doc --> (key --> list(value,mtime))) !nested dict

    if {$type eq {}} { set type array::base }
    if {$user eq {}} { set user $::tcl_platform(user) }
    if {$when eq {}} { set when [clock seconds] }

    set when   [FmtTime $when]
    set sorted [DictSort2 $dict]

    return [json::write::object \
		check [json::write::string [Checksum $sorted type $type user $user when $when]] \
		data  [json::write::object {*}[Process2 $sorted]] \
		type  [json::write::string $type] \
		user  [json::write::string $user] \
		when  [json::write::string $when]]
}

proc ::phash::multitime::serial::json-extended::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::multitime::serial::json-extended::Checksum {dict args} {
    set s {}
    foreach {k v} $dict {
	append s "[string length $k] $k [llength $v]\n"
	foreach item $v {
	    append s "[string length $item] $item\n"
	}
    }
    foreach item $args {
	append s "[string length $item] $item\n"
    }
    return [string tolower [md5::md5 -hex -- $s]]
}

proc ::phash::multitime::serial::json-extended::Process2 {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::object {*}[Process $v]]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-extended::Process {dict} {
    set tmp {}
    foreach {k v} $dict {
	lassign $v value mtime
	set v [json::write::string $value]
	set t [json::write::string [FmtTime $mtime]]
	lappend tmp $k [json::write::array $v $t]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-extended::DictSort2 {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [DictSort [dict get $dict $k]]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-extended::DictSort {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [dict get $dict $k]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-extended::FmtTime {t} {
    return [clock format $t -gmt 1 -format {%Y-%m-%dT%H:%M:%S}]
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::multitime::serial::json-extended {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::multitime::serial::json-extended 0
return
