# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

# @@ Meta Begin
# Package phash::multi::serial::json-extended 0
# Meta author      ?
# Meta category    ?
# Meta description ?
# Meta location    http:/core.tcl.tk/akupries/array
# Meta platform    tcl
# Meta require     ?
# Meta subject     ?
# Meta summary     ?
# @@ Meta End

## Commands to convert 'multi' arrays into json and back.
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

namespace eval ::phash::multi::serial::json-extended {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::multi::serial::json-extended::generate {dict {type {}} {user {}} {when {}}} {
    if {$type eq {}} { set type array::base }
    if {$user eq {}} { set user $::tcl_platform(user) }
    if {$when eq {}} { set when [clock seconds] }

    set when   [clock format $when -gmt 1 -format {%Y-%m-%dT%H:%M:%S}]
    set sorted [DictSort2 $dict]

    return [json::write::object \
		check [json::write::string [Checksum $sorted type $type user $user when $when]] \
		data  [json::write::object {*}[Process2 $sorted]] \
		type  [json::write::string $type] \
		user  [json::write::string $user] \
		when  [json::write::string $when]]
}

proc ::phash::multi::serial::json-extended::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::multi::serial::json-extended::Checksum {dict args} {
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

proc ::phash::multi::serial::json-extended::Process2 {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::object {*}[Process $v]]
    }
    return $tmp
}

proc ::phash::multi::serial::json-extended::Process {dict} {
    set tmp {}
    foreach {k v} $dict {
	lappend tmp $k [json::write::string $v]
    }
    return $tmp
}

proc ::phash::multi::serial::json-extended::DictSort2 {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [DictSort [dict get $dict $k]]
    }
    return $tmp
}

proc ::phash::multi::serial::json-extended::DictSort {dict} {
    set tmp {}
    foreach k [lsort -dict [dict keys $dict]] {
	lappend tmp $k [dict get $dict $k]
    }
    return $tmp
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::multi::serial::json-extended {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::multi::serial::json-extended 0
return
