## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    phash::multi::memory create mymulti
    rename [mymulti open ABC] myphash
    return myphash
}

proc release-store {} {
    myphash destroy
    mymulti destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
