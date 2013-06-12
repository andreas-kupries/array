## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc store-class-methods {} { U [class-methods]      [sqlite-methods] }
proc store-instc-methods {} { U [core-instc-methods] [sqlite-methods] [time-instc-methods] }

proc new-store {} {
    sqlite3              test-database :memory:
    [store-class] create test-store    ::test-database phash
    return
}

proc release-store {} {
    catch { test-store    destroy }
    catch { test-database close   }
    return
}

# # ## ### ##### ######## ############# #####################
return
