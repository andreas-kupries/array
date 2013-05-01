## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    [test-class] create myphash
    return
}

proc release-store {} {
    myphash destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
