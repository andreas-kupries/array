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
    # mymap: dict (key --> value)

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.

    # # ## ### ##### ######## #############
    ### Retrieval and query operations.

    # size: () --> integer
    method size {} { dict size $mymap }

    # names: ?pattern? --> list(string)
    method names {{pattern *}} { dict keys $mymap $pattern }

    # exists: string --> boolean
    method exists {key} { dict exists $mymap $key }

    # get: ?pattern? --> dict (key --> value)
    method get {{pattern *}} { dict filter $mymap key $pattern }

    # getv: key --> value
    method getv {key} {
	my Validate $key
	dict get $mymap $key
    }

    # value: ?pattern? --> dict (key --> value)
    method value {{pattern *}} { dict filter $mymap value $pattern }

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} {
	set mymap [dict merge $mymap $dict]
	return
    }

    # setv: (key, value) --> value
    method setv {key value} {
	dict set mymap $key $value
	return $value
    }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} {
	if {$pattern eq "*"} {
	    set mymap {}
	} else {
	    set mymap [dict remove $mymap {*}[dict keys $mymap $pattern]]
	}
	return    
    }

    # unsetv: key --> ()
    method unsetv {key} {
	my Validate $key
	dict unset mymap $key
	return
    }

    # clear: () --> ()
    method clear {} { set mymap {} }

    # # ## ### ##### ######## #############

    method Validate {key} {
	if {[dict exists $mymap $key]} return
	my Error "Expected key, got \"$key\"" BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::memory 0
return
