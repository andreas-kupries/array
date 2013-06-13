## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { test-class }

proc store-class-methods {} { class-methods      }
proc store-instc-methods {} { U [core-instc-methods] [list-instc-methods] }

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
