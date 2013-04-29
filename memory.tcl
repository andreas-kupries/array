# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory phash storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::memory {
    superclass phash

    # # ## ### ##### ######## #############
    ## State

    variable mymap
    # mymap: array (key -> value)

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # get: () -> dict
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
    method setv {key value} { set mymap($key) $value }

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

    method Validate {key} {
	if {[info exists mymap($key)]} return
	my Error "Expected key, got \"$key\"" \
	    BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::memory 0
return
