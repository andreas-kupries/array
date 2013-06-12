# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## Commands to convert 'mtime' arrays into json and back.
## The intermediate representation is a Tcl dictionary.
## This package generates a simple json representation, just
## mapping keys and values into a single JSON object.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require json
package require json::write ; # config (indented|aligned) is left to user.

namespace eval ::phash::mtime::serial::json-simple {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::mtime::serial::json-simple::generate {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lassign [dict get $dict $k] v t
	set v [json::write::string $v]
	set t [json::write::string [FmtTime $t]]
	lappend tmp $k [json::write::array $v $t]
    }
    return [json::write::object {*}$tmp]
}

proc ::phash::mtime::serial::json-simple::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::mtime::serial::json-simple::FmtTime {t} {
    return [clock format $t -gmt 1 -format {%Y-%m-%dT%H:%M:%S}]
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::mtime::serial::json-simple {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::mtime::serial::json-simple 0
return
