# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory phash::mtime storage.

# @@ Meta Begin
# Package phash::mtime::memory 0
# Meta author      ?
# Meta category    ?
# Meta description ?
# Meta location    http:/core.tcl.tk/akupries/array
# Meta platform    tcl
# Meta require     ?
# Meta subject     ?
# Meta summary     ?
# @@ Meta End

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
    # mymap:  dict (key --> value)
    # mytime: dict (key --> mtime)

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
	set now [clock seconds]
	dict for {k v} $dict {
	    dict set mymap  $k $v
	    dict set mytime $k $now
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
	dict set mytime $key $time
	dict set mymap  $key $value
	return $value
    }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} {
	if {$pattern eq "*"} {
	    set mymap  {}
	    set mytime {}
	} else {
	    set mymap  [dict remove $mymap  {*}[dict keys $mymap  $pattern]]
	    set mytime [dict remove $mytime {*}[dict keys $mytime $pattern]]
	}
	return
    }

    # unsetv: key --> ()
    method unsetv {key} {
	my Validate $key
	dict unset mymap  $key
	dict unset mytime $key
	return
    }

    # clear: () --> ()
    method clear {} {
	set mymap  {}
	set mytime {}
	return
    }

    # # ## ### ##### ######## #############
    ## Additional acessors to query and change last modified
    ## information, bulk and for individual keys.

    # get-time: ?pattern? --> dict (key --> mtime)
    method get-time {{pattern *}} { dict filter $mytime key $pattern }

    # get-timev: key --> mtime
    method get-timev {key} {
	my Validate $key
	dict get $mytime $key
    }
    # set-timev: (key, time) --> time
    method set-timev {key time} {
	my Validate     $key
	my ValidateTime $time
	dict set mytime $key $time
	return $time
    }

    # # ## ### ##### ######## #############
    ## Internal support.

    method Validate {key} {
	if {[dict exists $mymap $key]} return
	my Error "Expected key, got \"$key\"" \
	    BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::mtime::memory 0
return
