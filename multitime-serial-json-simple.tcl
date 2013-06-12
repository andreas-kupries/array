# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## Commands to convert 'multitime' arrays into json and back.
## The intermediate representation is a Tcl dictionary.
## This package generates a simple json representation, just
## mapping keys and values into a single JSON object.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require json
package require json::write ; # config (indented|aligned) is left to user.

namespace eval ::phash::multitime::serial::json-simple {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::multitime::serial::json-simple::generate {dict} {
    # dict (doc --> (key --> list(value,mtime))) !nested dict
    return [json::write::object {*}[Process2 [DictSort2 $dict]]]
}

proc ::phash::multitime::serial::json-simple::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::multitime::serial::json-simple::Process2 {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::object {*}[Process $v]]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-simple::Process {dict} {
    set tmp {}
    foreach {k v} $dict {
	lassign $v value mtime
	set v [json::write::string $value]
	set t [json::write::string [FmtTime $mtime]]
	lappend tmp $k [json::write::array $v $t]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-simple::DictSort2 {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [DictSort [dict get $dict $k]]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-simple::DictSort {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [dict get $dict $k]
    }
    return $tmp
}

proc ::phash::multitime::serial::json-simple::FmtTime {t} {
    return [clock format $t -gmt 1 -format {%Y-%m-%dT%H:%M:%S}]
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::multitime::serial::json-simple {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::multitime::serial::json-simple 0
return
