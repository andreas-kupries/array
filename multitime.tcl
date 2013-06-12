# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for array storage i.e. Persistent HASH tables.
## --> Extended to maintain multiple base hashes per instance, plus
## last modified information per key.
##
## See also Tcllib 'tie'. We are using a compatible instance API.
##
## This class declares the API all actual classes have to
## implement. It also provides standard APIs for the
## de(serialization) of array stores.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require phash::mtime

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::multitime {
    # # ## ### ##### ######## #############
    ## API. Standard methods.

    # open: name --> phash instance
    method open {doc} {
	return [::phash::multitime::Doc new [self] $doc]
    }

    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.
    #
    ## Helper class API providing access to named partitions,
    ## i.e. documents of the multi-time instance. This API is essentially
    ## the 'mtime' API, with just the partition key added as first
    ## argument.

    # size () --> integer
    method _size {doc} { my APIerror _size }

    # names: ?pattern? --> list(string)
    method _names {doc {pattern *}} { my APIerror _names }

    # exists: key --> boolean
    method _exists {doc key} { my APIerror _exists }

    # get: ?pattern? --> dict (key --> value)
    method _get {doc {pattern *}} { my APIerror _get }

    # getv: key --> value
    method _getv {doc key} { my APIerror _getv }

    # value: ?pattern? --> dict (key --> value)
    method _value {doc {pattern *}} { my APIerror _value }

    # set: dict (key --> value) --> ()
    method _set {doc dict} { my APIerror _set }

    # setv: (key, value, ?time?) --> value
    method _setv {doc key value {time {}}} { my APIerror _setv }

    # unset: ?pattern? --> ()
    method _unset {doc {pattern *}} { my APIerror _unset }

    # unsetv: (key) --> ()
    method _unsetv {doc key} { my APIerror _unsetv }

    # clear () --> ()
    method _clear {doc} { my _unset $doc }
    # clear <==> 'unset *' <==> 'unset'

    # get-time: ?pattern? --> dict (key --> mtime)
    method _gettime {doc {pattern *}} { my APIerror _gettime }

    # get-timev: key --> mtime
    method _gettimev {doc key} { my APIerror _gettimev }

    # set-timev: (key, time) --> time
    method _settimev {doc key time} { my APIerror _settimev }

    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.
    #
    ## Global API for overall (document independent access).

    # size: () --> integer
    method size {} { my APIerror size }

    # names: ?pattern? --> list(string)
    method names {{pattern *}} { my APIerror names }

    # keys: ?pattern? --> list(string)
    method keys {{pattern *}} { my APIerror keys }

    # get: ?pattern? --> (dict (key --> (doc --> value)))
    method get {{pattern *}} { my APIerror get }

    # getv: key --> (dict (doc --> value))
    method getv {key} { my APIerror getv }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} { my APIerror unset }

    # unsetv: key --> ()
    method unsetv {key} { my APIerror unsetv }

    # clear: () --> ()
    method clear {} { my APIerror clear }

    # # ## ### ##### ######## #############
    ## (De)serialization.

    method export {format args} {
	package require phash::multitime::serial::$format
	set all {}
	foreach doc [my names] {
	    # Retrieve separate value and time maps per document, and
	    # merge them. Consider creating an mtime API method to
	    # hide the structure.
	    set vmap [my _get     $doc]
	    set tmap [my _gettime $doc]
	    set vt {}
	    foreach k [dict keys $vmap] {
		dict set vt $k [list [dict get $vmap $k] [dict get $tmap $k]]
	    }
	    dict set all $doc $vt
	}
	return [phash::multitime::serial::$format generate $all {*}$args]
    }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	return -code error -errorcode [list PHASH {*}$args] $text
    }

    method APIerror {api} {
	my Error "Unimplemented API $api" API MISSING $api
    }

    method ValidateTime {t} {
	if {[string is integer -strict $t]} return
	my Error "Expected a time, got \"$t\"" PHASH MTIME BAD TIME $t
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
## Helper class, derived from phash::mtime, linking to a named
## document in the multi-time instance.

oo::class create phash::multitime::Doc {
    superclass phash::mtime

    constructor {multi doc} {
	# The API is implemented as forwards from this instance to the
	# multi-time store, properly prefixing all methods with the
	# name of the document to access. No local state is kept, at
	# all.

	set mymulti [info object namespace $multi]::my

	oo::objdefine [self] forward size   $mymulti _size   $doc
	oo::objdefine [self] forward names  $mymulti _names  $doc
	oo::objdefine [self] forward exists $mymulti _exists $doc

	oo::objdefine [self] forward get    $mymulti _get    $doc
	oo::objdefine [self] forward getv   $mymulti _getv   $doc
	oo::objdefine [self] forward value  $mymulti _value  $doc

	oo::objdefine [self] forward set    $mymulti _set    $doc
	oo::objdefine [self] forward setv   $mymulti _setv   $doc

	oo::objdefine [self] forward unset  $mymulti _unset  $doc
	oo::objdefine [self] forward unsetv $mymulti _unsetv $doc
	oo::objdefine [self] forward clear  $mymulti _clear  $doc

	oo::objdefine [self] forward get-time  $mymulti _gettime  $doc
	oo::objdefine [self] forward get-timev $mymulti _gettimev $doc
	oo::objdefine [self] forward set-timev $mymulti _settimev $doc
	return
    }
}

# # ## ### ##### ######## ############# #####################
package provide phash::multitime 0
return
