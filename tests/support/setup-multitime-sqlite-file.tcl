## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc store-class-methods {} { class-methods }
proc store-instc-methods {} { U [core-instc-methods] [time-instc-methods] }

proc multi-store-class-methods {} { U [class-methods]       [sqlite-methods] }
proc multi-store-instc-methods {} { U [multi-instc-methods] [sqlite-methods] }

proc new-store {} {
    sqlite3              test-database    [file normalize _phash_[pid]_]
    [store-class] create test-multi-store ::test-database phash
    rename [test-multi-store open ABC] test-store
    rename [test-multi-store open XYZ] test-doc-store
    return test-store
}

proc release-store {} {
    catch { test-store destroy }
    catch { test-doc-store   destroy }
    catch { test-multi-store destroy }
    catch { test-database    close   }
    file delete [file normalize _phash_[pid]_]
    return
}

# # ## ### ##### ######## ############# #####################
return
