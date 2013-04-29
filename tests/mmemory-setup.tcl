## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    return [mphash::memory create mymphash]
}

proc release-store {} {
    mymphash destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
