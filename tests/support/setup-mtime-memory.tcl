## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    return [phash::mtime::memory create mtime]
}

proc release-store {} {
    mtime destroy
    return
}

# # ## ### ##### ######## ############# #####################
return
