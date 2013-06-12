# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory phash::multitime storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::multitime

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::multitime::memory {
    superclass phash::multitime

    # # ## ### ##### ######## #############
    ## State

    variable mymap mytime
    # mymap:  dict (doc --> dict (key --> value))
    # mytime: dict (doc --> dict (key --> mtime))

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.
    ##      Access to individual documents.

    # size: () --> integer
    method _size {doc} {
	if {![dict exists $mymap $doc]} {return 0}
	dict size [dict get $mymap $doc]
    }

    # names: ?pattern? --> list(string)
    method _names {doc {pattern *}} {
	if {![dict exists $mymap $doc]} {return {}}
	dict keys [dict get $mymap $doc] $pattern
    }

    # exists: key --> boolean
    method _exists {doc key} {
	if {![dict exists $mymap $doc]} {return 0}
	dict exists $mymap $doc $key
    }

    # get: ?pattern? --> dict (key --> value)
    method _get {doc {pattern *}} {
	if {![dict exists $mymap $doc]} {return {}}
	dict filter [dict get $mymap $doc] key $pattern
    }

    # value: ?pattern? --> dict (key --> value)
    method _value {doc {pattern *}} {
	if {![dict exists $mymap $doc]} {return {}}
	dict filter [dict get $mymap $doc] value $pattern
    }

    # getv: key --> value
    method _getv {doc key} {
	my Validate $doc $key
	dict get $mymap $doc $key
    }

    # set: dict (key --> value) --> ()
    method _set {doc dict} {
	set now [clock seconds]
	if {![dict exists $mymap $doc]} {
	    dict set mymap $doc $dict
	} else {
	    set mymap [dict replace $mymap $doc \
			   [dict merge \
				[dict get $mymap $doc] \
				$dict]]
	}
	dict for {k _} $dict {
	    dict set mytime $doc $k $now
	}
	return
    }

    # setv: (key value ?time?) --> value
    method _setv {doc key value {time {}}} {
	if {[llength [info level 0]] < 6} {
	    set time [clock seconds]
	} else {
	    my ValidateTime $time
	}
	dict set mymap  $doc $key $value
	dict set mytime $doc $key $time
	return $value
    }

    # unset: ?pattern? --> ()
    method _unset {doc {pattern *}} {
	if {![dict exists $mymap $doc]} return
	if {$pattern eq "*"} {
	    dict unset mymap  $doc
	    dict unset mytime $doc
	} else {
	    foreach k [dict keys [dict get $mymap $doc] $pattern] {
		dict unset mymap  $doc $k
		dict unset mytime $doc $k
	    }
	}
	return
    }

    # unsetv: key --> ()
    method _unsetv {doc key} {
	my Validate $doc $key
	dict unset mymap  $doc $key
	dict unset mytime $doc $key
	return
    }

    # clear: () --> ()
    method _clear {doc} {
	if {![dict exists $mymap $doc]} return
	dict unset mymap $doc
	return
    }

    # get-time: ?pattern? --> dict (key --> mtime)
    method _gettime {doc {pattern *}} {
	if {![dict exists $mytime $doc]} {return {}}
	dict filter [dict get $mytime $doc] key $pattern
    }

    # get-timev: key --> mtime
    method _gettimev {doc key} {
	my Validate $doc $key
	dict get $mytime $doc $key
    }

    # set-timev: (key, time) --> time
    method _settimev {doc key time} {
	dict set mytime $doc $key $time
	return $time
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.
    #
    ## Global API for overall (document independent access).

    # size: () --> integer
    method size {} { dict size $mymap }

    # names: ?pattern? --> list(string)
    method names {{pattern *}} { dict keys $mymap $pattern }

    # keys: ?pattern? --> list(string)
    method keys {{pattern *}} {
	set r {}
	dict for {doc partition} $mymap {
	    lappend r {*}[dict keys $partition $pattern]
	    set r [lsort -unique $r]
	}
	return $r
    }

    # get: ?pattern? --> (dict (key --> (doc --> value)))
    method get {{pattern *}} {
	set r {}
	dict for {doc partition} $mymap {
	    foreach k [dict keys $partition $pattern] {
		dict set r $k $doc [dict get $partition $k]
	    }
	}
	return $r
    }

    # getv: key --> (dict (doc --> value))
    method getv {key} {
	set r {}
	dict for {doc partition} $mymap {
	    if {![dict exists $partition $key]} continue
	    dict set r $doc [dict get $partition $key]
	}
	return $r
    }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} {
	dict for {doc partition} $mymap {
	    foreach k [dict keys $partition $pattern] {
		dict unset partition $k
	    }
	    dict set mymap $doc $partition
	}
	dict for {doc partition} $mytime {
	    foreach k [dict keys $partition $pattern] {
		dict unset partition $k
	    }
	    dict set mytime $doc $partition
	}
	return
    }

    # unsetv: key --> ()
    method unsetv {key} {
	dict for {doc partition} $mymap {
	    dict unset partition $key
	    dict set mymap $doc $partition
	}
	dict for {doc partition} $mytime {
	    dict unset partition $key
	    dict set mytime $doc $partition
	}
	return
    }

    # clear: () --> ()
    method clear {} {
	set mymap  {}
	set mytime {}
	return
    }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Validate {doc key} {
	if {[dict exists $mymap $doc $key]} return
	my Error "Expected key, got \"$key\"" BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::multitime::memory 0
return
