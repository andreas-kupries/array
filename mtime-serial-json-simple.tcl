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

namespace eval ::phash::mtime::serial::json-simple {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::mtime::serial::json-simple::generate {dictv dictt} {
    set kv [lsort -dict [dict keys $dictv]]
    set kt [lsort -dict [dict keys $dictt]]
    if {$kv ne $kt} {
	return -code error -errorcode {PHASH MTIME SERIAL JSON-SIMPLE GEN BAD} \
	    "Data mismatch between value and time dictionaries"
    }
    set tmp {}
    foreach k $kv {
	set v [json::write::string [dict get $dictv $k]]
	set t [json::write::string [FmtTime [dict get $dictt $k]]]
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
