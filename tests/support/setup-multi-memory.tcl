## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

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
