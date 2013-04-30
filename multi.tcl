# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for array storage i.e. Persistent HASH tables.
## --> Extended to maintain a multiple base hashes per instance.
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
package require phash

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::multi {
    # # ## ### ##### ######## #############
    ## API. Standard methods.

    # open: name --> phash instance
    method open {doc} {
	return [::phash::multi::Doc new [self] $doc]
    }

    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.
    #
    ## Helper class API providing access to named partitions,
    ## i.e. documents of the multi instance

    # open: () --> ()
    method _open {doc} { my APIerror _open }

    # get: pattern? --> dict
    method _get {doc {pattern *}} { my APIerror _get }

    # set: dict --> ()
    method _set {doc dict} { my APIerror _set }

    # unset: pattern? --> ()
    method _unset {doc {pattern *}} { my APIerror _unset }

    # getv: key --> value
    method _getv {doc key} { my APIerror _getv }

    # setv: (key, value) --> value
    method _setv {doc key value} { my APIerror _setv }

    # unsetv: (key) --> ()
    method _unsetv {doc key} { my APIerror _unsetv }

    # names pattern? --> list(string)
    method _names {doc {pattern *}} { my APIerror _names }

    # exists: key --> boolean
    method _exists {doc key} { my APIerror _exists }

    # size () --> integer
    method _size {doc} { my APIerror _size }

    # clear () --> ()
    method _clear {doc} { my APIerror _clear }

    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.
    #
    ## Global API for overall (document independent access).

    # get: pattern? --> (dict doc --> list (value))
    method get {{pattern *}} { my APIerror get }

    # unset: pattern? --> ()
    method unset {{pattern *}} { my APIerror unset }

    # getv: key --> (dict doc --> list (value))
    method getv {key} { my APIerror getv }

    # unsetv: key --> ()
    method unsetv {key} { my APIerror unsetv }

    # names: pattern? --> list(string)
    method names {{pattern *}} { my APIerror names }

    # size: () --> integer
    method size {} { my APIerror size }

    # clear: () --> ()
    method clear {} { my APIerror clear }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	return -code error -errorcode [list PHASH {*}$args] $text
    }

    method APIerror {api} {
	my Error "Unimplemented API $api" API MISSING $api
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
## Helper class, derived from phash, linking to a named
## document in the multi instance.

oo::class create phash::multi::Doc {
    superclass phash

    constructor {multi doc} {
	# The API is implemented as forwards from this instance to the
	# multi store, properly prefixing all methods with the name of
	# the document to access. No local state at all.

	set mymulti [info object namespace $multi]::my

	oo::objdefine [self] forward clear  $mymulti _clear  $doc
	oo::objdefine [self] forward exists $mymulti _exists $doc
	oo::objdefine [self] forward get    $mymulti _get    $doc
	oo::objdefine [self] forward getv   $mymulti _getv   $doc
	oo::objdefine [self] forward names  $mymulti _names  $doc
	oo::objdefine [self] forward set    $mymulti _set    $doc
	oo::objdefine [self] forward setv   $mymulti _setv   $doc
	oo::objdefine [self] forward size   $mymulti _size   $doc
	oo::objdefine [self] forward unset  $mymulti _unset  $doc
	oo::objdefine [self] forward unsetv $mymulti _unsetv $doc

	$mymulti _open $doc
	return
    }
}

# # ## ### ##### ######## ############# #####################
package provide phash::multi 0
return
