# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

# @@ Meta Begin
# Package phash::serial::json-simple 0
# Meta author      ?
# Meta category    ?
# Meta description ?
# Meta location    http:/core.tcl.tk/akupries/array
# Meta platform    tcl
# Meta require     ?
# Meta subject     ?
# Meta summary     ?
# @@ Meta End

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
    foreach {k v} $dict {
	lappend tmp $k [json::write::string $v]
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
