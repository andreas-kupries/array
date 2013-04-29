## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    return [phash::memory create myphash]
}

proc release-store {} {
    myphash destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
