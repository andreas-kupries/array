# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory mphash storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require mphash

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create mphash::memory {
    superclass mphash

    # # ## ### ##### ######## #############
    ## State

    variable mymap mytime
    # mymap:  array (key -> value)
    # mytime: array (key -> time)

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # get: () -> dict (values)
    method get {} { array get mymap }

    # set: dict -> ()
    method set {dict} { array set mymap $dict }

    # unset: (pattern?) -> ()
    method unset {{pattern *}} { array unset mymap $pattern }

    # getv: (key) -> value
    method getv {key} {
	my Validate $key
	return $mymap($key)
    }

    # setv: (key, value) -> value
    method setv {key value {time {}}} {
	if {[llength [info level 0]] < 5} {
	    set time [clock seconds]
	} else {
	    # TODO: check time (epoch, integer!)
	}
	set mytime($key) $time
	set mymap($key)  $value
    }

    # unsetv: (key) -> ()
    method unsetv {key} {
	my Validate $key
	unset mymap($key)
    }

    # names () -> list(string)
    method names {} { array names mymap }

    # exists: string -> boolean
    method exists {key} { info exists mymap($key) }

    # size () -> integer
    method size {} { array size mymap }

    # clear () -> ()
    method clear {} { array unset mymap * }

    # # ## ### ##### ######## #############

    # gett: () -> dict (mtimes)
    method gett {} { array get mytime }

    # gettv: (key) -> mtime
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
package provide mphash::memory 0
return
