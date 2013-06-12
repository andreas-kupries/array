## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { test-class }

proc store-class-methods {} { return {create destroy new} }
proc store-instc-methods {} { return {clear destroy exists export get getv names set setv size unset unsetv} }

proc multi-store-class-methods {} { return {create destroy new} }
proc multi-store-instc-methods {} { return {clear destroy export get getv keys names open size unset unsetv} }

proc new-store {} {
    [test-class] create test-multi-store
    rename [test-multi-store open ABC] test-store
    rename [test-multi-store open XYZ] test-doc-store
    return
}

proc release-store {} {
    test-store       destroy
    test-doc-store   destroy
    test-multi-store destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
