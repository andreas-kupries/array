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
    # mymap: array (key --> value)

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

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} {
	array set mymap $dict
	return
    }

    # setv: (key, value) --> value
    method setv {key value} { set mymap($key) $value }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} {
	array unset mymap $pattern
	return    
    }

    # unsetv: key --> ()
    method unsetv {key} {
	my Validate $key
	unset mymap($key)
    }

    # clear: () --> ()
    method clear {} { array unset mymap * }

    # # ## ### ##### ######## #############

    method Validate {key} {
	if {[info exists mymap($key)]} return
	my Error "Expected key, got \"$key\"" BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::memory 0
return
