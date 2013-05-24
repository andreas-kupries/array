# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## Commands to convert 'base' arrays into json and back.
## The intermediate representation is a Tcl dictionary.
## This package generates a simple json representation, just
## mapping keys and vaues into a single JSON object.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require json
package require json::write ; # config (indented|aligned) is left to user.

namespace eval ::phash::multi::serial::json-simple {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::multi::serial::json-simple::generate {dict} {
    # dict (doc --> (key --> value)) !nested dict
    return [json::write::object {*}[Process2 [DictSort2 $dict]]]
}

proc ::phash::multi::serial::json-simple::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::multi::serial::json-simple::Process2 {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::object {*}[Process $v]]
    }
    return $tmp
}

proc ::phash::multi::serial::json-simple::Process {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::string $v]
    }
    return $tmp
}

proc ::phash::multi::serial::json-simple::DictSort2 {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [DictSort [dict get $dict $k]]
    }
    return $tmp
}

proc ::phash::multi::serial::json-simple::DictSort {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [dict get $dict $k]
    }
    return $tmp
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::multi::serial::json-simple {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::multi::serial::json-simple 0
return
