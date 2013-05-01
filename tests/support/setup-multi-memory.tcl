## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    [test-class] create mymulti
    rename [mymulti open ABC] myphash
    rename [mymulti open XYZ] mydoc
    return
}

proc release-store {} {
    myphash destroy
    mydoc   destroy
    mymulti destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
