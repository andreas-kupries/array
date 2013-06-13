# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for list-valued array storage.
##
## This class declares the API all actual classes have to
## implement. It also provides standard APIs for the
## de(serialization) of array stores.

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO

# # ## ### ##### ######## ############# #####################
## Implementation

oo::class create phash::list {
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

    # setv: (key, value...) --> value...
    method setv {key value args} { my APIerror setv }

    # append: (key, value...) --> value...
    method append {key value args} { my APIerror append }

    # remove: (key, value...) --> ()
    method remove {key value args} { my APIerror remove }

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
	package require phash::list::serial::$format
	return [phash::list::serial::$format generate [my get] {*}$args]
    }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	return -code error -errorcode [list PHASH LIST {*}$args] $text
    }

    method APIerror {api} {
	my Error "Unimplemented API $api" API MISSING $api
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide phash::list 0
return
