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

namespace eval ::phash::serial::json-simple {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::serial::json-simple::generate {dict} {
    return [json::write::object {*}[Process [DictSort $dict]]]
}

proc ::phash::serial::json-simple::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::serial::json-simple::Process {dict} {
    set tmp {}
    foreach {k vlist} $dict {
	set vx {}
	foreach v $vlist {
	    lappend vx [json::write::string $v]
	}
	lappend tmp $k [json::write::array {*}$vx]
    }
    return $tmp
}

proc ::phash::serial::json-simple::DictSort {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [dict get $dict $k]
    }
    return $tmp
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::serial::json-simple {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::serial::json-simple 0
return
