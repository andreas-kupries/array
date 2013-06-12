# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory phash::mtime storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::mtime

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::mtime::memory {
    superclass phash::mtime

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # # ## ### ##### ######## #############
    ### Retrieval and query operations.

    # size: () --> integer
    method size {} { array size mymap }

    # names: ?pattern? --> list(string)
    method names {{pattern *}} { array names mymap $pattern }

    # exists: string --> boolean
    method exists {key} { info exists mymap($key) }

    # get: ?pattern? --> dict (key --> value)
    method get {{pattern *}} { array get mymap $pattern }

    # getv: key --> value
    method getv {key} {
	my Validate $key
	return $mymap($key)
    }

    # value: ?pattern? --> dict (key --> value)
    method value {{pattern *}} {
	set result {}
	foreach k [array names mymap] {
	    set v $mymap($k)
	    if {![string match $pattern $v]} continue
	    dict set result $k $v
	}
	return $result
    }

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} {
	set now [clock seconds]
	array set mymap $dict
	dict for {k _} $dict {
	    set mytime($k) $now
	}
	return
    }

    # setv: (key, value, ?time?) --> value
    method setv {key value {time {}}} {
	if {[llength [info level 0]] < 5} {
	    set time [clock seconds]
	} else {
	    my ValidateTime $time
	}
	set mytime($key) $time
	set mymap($key)  $value
    }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} {
	array unset mymap  $pattern
	array unset mytime $pattern
	return
    }

    # unsetv: key --> ()
    method unsetv {key} {
	my Validate $key
	unset mymap($key)
	unset mytime($key)
	return
    }

    # clear: () --> ()
    method clear {} {
	array unset mymap  *
	array unset mytime *
	return
    }

    # # ## ### ##### ######## #############
    ## Additional acessors to query and change last modified
    ## information, bulk and for individual keys.

    # get-time: ?pattern? --> dict (key --> mtime)
    method get-time {{pattern *}} { array get mytime $pattern }

    # get-timev: key --> mtime
    method get-timev {key} {
	my Validate $key
	return $mytime($key)
    }
    # set-timev: (key, time) --> time
    method set-timev {key time} {
	my Validate     $key
	my ValidateTime $time
	set mytime($key) $time
	return $time
    }

    # # ## ### ##### ######## #############
    ## State

    variable mymap mytime
    # mymap:  array (key --> value)
    # mytime: array (key --> mtime)

    # # ## ### ##### ######## #############
    ## Internal support.

    method Validate {key} {
	if {[info exists mymap($key)]} return
	my Error "Expected key, got \"$key\"" \
	    BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::mtime::memory 0
return
