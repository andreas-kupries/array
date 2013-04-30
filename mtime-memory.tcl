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
    ## State

    variable mymap mytime
    # mymap:  array (key --> value)
    # mytime: array (key --> mtime)

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # get: () --> dict (key -> value)
    method get {{pattern *}} { array get mymap $pattern }

    # set: dict --> ()
    method set {dict} {
	array set mymap $dict
	return
    }

    # unset: pattern? --> ()
    method unset {{pattern *}} {
	array unset mymap $pattern
	return
    }

    # getv: key --> value
    method getv {key} {
	my Validate $key
	return $mymap($key)
    }

    # setv: (key, value, time?) --> value
    method setv {key value {time {}}} {
	if {[llength [info level 0]] < 5} {
	    set time [clock seconds]
	} else {
	    my ValidateTime $time
	}
	set mytime($key) $time
	set mymap($key)  $value
    }

    # unsetv: key --> ()
    method unsetv {key} {
	my Validate $key
	unset mymap($key)
    }

    # names: pattern? --> list(string)
    method names {{pattern *}} { array names mymap $pattern }

    # exists: string --> boolean
    method exists {key} { info exists mymap($key) }

    # size: () --> integer
    method size {} { array size mymap }

    # clear: () --> ()
    method clear {} { array unset mymap * }

    # # ## ### ##### ######## #############

    # gett: () --> dict (mtimes)
    method gett {{pattern *}} { array get mytime $pattern }

    # gettv: key --> mtime
    method gettv {key} {
	my Validate $key
	return $mytime($key)
    }

    # # ## ### ##### ######## #############

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
