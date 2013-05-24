# -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Base class for array storage i.e. Persistent HASH tables,
## --> Extended to maintain a last modified information per key.
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

oo::class create phash::mtime {
    # # ## ### ##### ######## #############
    ## API. Virtual methods. Implementation required.

    # # ## ### ##### ######## #############
    ### Retrieval and query operations.

    # size: () --> integer
    method size {} { my APIerror size }

    # names: ?pattern? --> list(key)
    method names {{pattern *}} { my APIerror names }

    # exists: key --> boolean
    method exists {key} { my APIerror exists }

    # get: ?pattern? --> dict (key --> value)
    method get {{pattern *}} { my APIerror get }

    # getv: key --> value
    method getv {key} { my APIerror getv }

    # Future: Queries by time range.
    #         - after   x,
    #         - before  x,
    #         - between x y
    #         - not-after   x,
    #         - not-before  x,
    #         - not-between x y

    # # ## ### ##### ######## #############
    ### Modifying operations.

    # set: dict (key --> value) --> ()
    method set {dict} { my APIerror set }

    # setv: (key, value, ?time?) --> value
    method setv {key value {time {}}} { my APIerror setv }

    # unset: ?pattern? --> ()
    method unset {{pattern *}} { my APIerror unset }

    # unsetv: key --> ()
    method unsetv {key} { my APIerror unsetv }

    # clear: () --> ()
    method clear {} { my unset }
    # clear <==> 'unset *' <==> 'unset'

    # # ## ### ##### ######## #############
    ## Additional acessors to query and change last modified
    ## information, bulk and for individual keys.

    # get-time: ?pattern? --> dict (key --> mtime)
    method get-time {{pattern *}} { my APIerror get-time }

    # get-timev: key --> mtime
    method get-timev {key} { my APIerror get-timev }

    # set-timev: (key, time) --> time
    method set-timev {key time} { my APIerror set-timev }

    # # ## ### ##### ######## #############
    ## (De)serialization.

    method export {format args} {
	package require phash::mtime::serial::$format
	return [phash::mtime::serial::$format generate \
		    [my get] [my get-time] \
		    {*}$args]
    }

    # # ## ### ##### ######## #############
    ## Internal helpers

    method Error {text args} {
	return -code error -errorcode [list PHASH MTIME {*}$args] $text
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
package provide phash::mtime 0
return
