## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    phash::multi::memory create mymulti
    rename [mymulti open ABC] myphash
    rename [mymulti open XYZ] mydoc
    return myphash
}

proc release-store {} {
    myphash destroy
    mydoc   destroy
    mymulti destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
