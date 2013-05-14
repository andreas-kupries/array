## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    sqlite3              test-database    :memory:
    [store-class] create test-multi-store ::test-database phash
    rename [test-multi-store open ABC] test-store
    rename [test-multi-store open XYZ] test-doc-store
    return
}

proc release-store {} {
    catch { test-store destroy }
    catch { test-doc-store   destroy }
    catch { test-multi-store destroy }
    catch { test-database    close   }
    return
}

# # ## ### ##### ######## ############# #####################
return
