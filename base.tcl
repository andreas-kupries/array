# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for array storage i.e. Persistent HASH tables.
## See also Tcllib 'tie'. We are using a compatible instance API.
##
## This class declares the API all actual classes have to
## implement. It also provides standard APIs for the
## de(serialization) of array stores.

# @@ Meta Begin
# Package phash 0
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

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash {
    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.

    # # ## ### ##### ######## #############
    ### Retrieval and query operations.

    # size: () --> integer
    method size {} { my APIerror size }

    # names: ?pattern? --> list(string)
    method names {{pattern *}} { my APIerror names }

    # exists: key --> boolean
    method exists {key} { my APIerror exists }

    # get: ?pattern? --> dict (key --> value)
    method get {{pattern *}} { my APIerror get }

    # getv: key --> value
    method getv {key} { my APIerror getv }

    # value: ?pattern? --> dict (key --> value)
    method value {{pattern *}} { my APIerror value }

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} { my APIerror set }

    # setv: (key, value) --> value
    method setv {key value} { my APIerror setv }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} { my APIerror unset }

    # unsetv: key --> ()
    method unsetv {key} { my APIerror unsetv }

    # clear: () --> ()
    method clear {} { my unset }
    # clear <==> 'unset *' <==> 'unset'

    # # ## ### ##### ######## #############
    ## (De)serialization.

    method export {format args} {
	package require phash::serial::$format
	return [phash::serial::$format generate [my get] {*}$args]
    }

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
package provide phash 0
return
