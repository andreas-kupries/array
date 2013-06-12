## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { test-class }

proc store-class-methods {} { return {create destroy new} }
proc store-instc-methods {} { return {clear destroy exists export get getv names set setv size unset unsetv} }

proc new-store {} {
    [test-class] create test-store
    return
}

proc release-store {} {
    test-store destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
