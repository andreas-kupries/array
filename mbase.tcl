# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for array storage i.e. Persistent HASH tables,
## --> with last modified information per key.
## See also Tcllib 'tie'. We are using a compatible instance API.
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

oo::class create mphash {
    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.

    # get: () -> dict (values only)
    method get {} { my APIerror get }

    # set: dict -> ()
    method set {dict} { my APIerror set }

    # unset: (pattern?) -> ()
    method unset {{pattern *}} { my APIerror unset }

    # getv: (key) -> value
    method getv {key} { my APIerror getv }

    # setv: (key, value) -> value
    method setv {key value {time {}}} { my APIerror setv }

    # unsetv: (key) -> ()
    method unsetv {key} { my APIerror unsetv }

    # names () -> list(string)
    method names {} { my APIerror names }

    # exists: key -> boolean
    method exists {key} { my APIerror exists }

    # size () -> integer
    method size {} { my APIerror size }

    # clear () -> ()
    method clear {} { my APIerror clear }

    # # ## ### ##### ######## #############
    ## Additional acessors to query last modified information, bulk
    ## and for individual keys.

    # get: () -> dict (mtimes only)
    method gett {} { my APIerror gett }

    # gettv: (key) -> mtime
    method gettv {key} { my APIerror gettv }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	return -code error -errorcode [list MPHASH {*}$args] $text
    }

    method APIerror {api} {
	my Error "Unimplemented API $api" API MISSING $api
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
package provide mphash 0
return
