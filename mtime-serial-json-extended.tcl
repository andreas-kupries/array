# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

## Commands to convert 'mtime' arrays into json and back.
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

namespace eval ::phash::mtime::serial::json-extended {}

# # ## ### ##### ######## ############# #####################
## API Implementation

proc ::phash::mtime::serial::json-extended::generate {dictv dictt {type {}} {user {}} {when {}}} {
    set kv [lsort -dict [dict keys $dictv]]
    set kt [lsort -dict [dict keys $dictt]]
    if {$kv ne $kt} {
	return -code error -errorcode {PHASH MTIME SERIAL JSON-SIMPLE GEN BAD} \
	    "Data mismatch between value and time dictionaries"
    }
    if {$type eq {}} { set type array::base }
    if {$user eq {}} { set user $::tcl_platform(user) }
    if {$when eq {}} { set when [clock seconds] }

    set when [FmtTime $when]

    set tmp {}
    foreach k $kv {
	set v [dict get $dictv $k]
	set t [FmtTime [dict get $dictt $k]]
	lappend sorted $k $t $v
	lappend tmp $k [json::write::array \
			    [json::write::string $v] \
			    [json::write::string $t]]
    }

    return [json::write::object \
		check [json::write::string [Checksum $sorted type $type user $user when $when]] \
		data  [json::write::object {*}$tmp] \
		type  [json::write::string $type]   \
		user  [json::write::string $user]   \
		when  [json::write::string $when]]
}

proc ::phash::mtime::serial::json-extended::parse {json} {
}

# # ## ### ##### ######## ############# #####################
## Internal support.

proc ::phash::mtime::serial::json-extended::FmtTime {t} {
    return [clock format $t -gmt 1 -format {%Y-%m-%dT%H:%M:%S}]
}

proc ::phash::mtime::serial::json-extended::Checksum {args} {
    set s {}
    foreach item $args {
	append s "[string length $item] $item\n"
    }
    return [string tolower [md5::md5 -hex -- $s]]
}

# # ## ### ##### ######## ############# #####################
## Publish API

namespace eval ::phash::mtime::serial::json-extended {
    namespace export generate parse
    namespace ensemble create
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide phash::mtime::serial::json-extended 0
return
