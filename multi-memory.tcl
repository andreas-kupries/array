# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## In-memory phash::multi storage.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::multi

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::multi::memory {
    superclass phash::multi

    # # ## ### ##### ######## #############
    ## State

    variable mymap
    # mymap: dict (doc --> dict (key --> value))

    # # ## ### ##### ######## #############
    ## Lifecycle.

    constructor {} { my clear }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.
    ##      Access to individual documents.

    method _open {doc} {
	if {[dict exists $mymap $doc]} return
	dict set mymap $doc {}
	return
    }

    # get: pattern? --> dict
    method _get {doc {pattern *}} {
	dict filter [dict get $mymap $doc] key $pattern
    }

    # set: dict --> ()
    method _set {doc dict} {
	set mymap [dict replace $mymap $doc \
		       [dict merge \
			    [dict get $mymap $doc] \
			    $dict]]
	return
    }

    # unset: pattern? --> ()
    method _unset {doc {pattern *}} {
	if {$pattern eq "*"} {
	    dict set mymap $doc {}
	} else {
	    foreach k [dict keys [dict get $mymap $doc] $pattern] {
		dict unset mymap $doc $k
	    }
	}
	return
    }

    # getv: key --> value
    method _getv {doc key} {
	my Validate $doc $key
	dict get $mymap $doc $key
    }

    # setv: (key value) --> value
    method _setv {doc key value} {
	dict set mymap $doc $key $value
	return $value
    }

    # unsetv: (key) --> ()
    method _unsetv {doc key} {
	my Validate $doc $key
	dict unset mymap $doc $key
	return
    }

    # names: pattern? --> list(string)
    method _names {doc {pattern *}} {
	dict keys [dict get $mymap $doc] $pattern
    }

    # exists: key --> boolean
    method _exists {doc key} {
	dict exists $mymap $doc $key
    }

    # size: () --> integer
    method _size {doc} {
	dict size [dict get $mymap $doc]
    }

    # clear: () --> ()
    method _clear {doc} {
	dict set mymap $doc {}
	return
    }

    # # ## ### ##### ######## #############
    ## API. Implementation of inherited virtual methods.
    #
    ## Global API for overall (document independent access).

    # get: pattern? --> (dict doc --> list (value))
    method get {{pattern *}} {
	set r {}
	dict for {doc partition} $mymap {
	    foreach k [dict keys $partition $pattern] {
		dict lappend r $k [dict get $partition $k]
	    }
	}
	return $r
    }

    # unset: pattern? --> ()
    method unset {{pattern *}} {
	dict for {doc partition} $mymap {
	    foreach k [dict keys $partition $pattern] {
		dict unset partition $k
	    }
	    dict set mymap $doc $partition
	}
	return
    }

    # getv: key --> (dict doc --> list (value))
    method getv {key} {
	set r {}
	dict for {doc partition} $mymap {
	    if {![dict exists $partition $key]} continue
	    dict lappend r $key [dict get $partition $key]
	}
	return $r
    }

    # unsetv: key --> ()
    method unsetv {key} {
	dict for {doc partition} $mymap {
	    dict unset partition $key
	    dict set mymap $doc $partition
	}
	return
    }

    # names: pattern? --> list(string)
    method names {{pattern *}} {
	set r {}
	dict for {doc partition} $mymap {
	    lappend r {*}[dict keys $partition $pattern]
	    set r [lsort -unique $r]
	}
	return $r
    }

    # size: () --> integer
    method size {} { dict size mymap }

    # clear: () --> ()
    method clear {} { set mymap {} ; return }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Validate {doc key} {
	if {[dict exists $mymap $doc $key]} return
	my Error "Expected key, got \"$key\"" BAD KEY $key
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::multi::memory 0
return
