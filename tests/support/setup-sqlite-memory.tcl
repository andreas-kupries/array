## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc store-class-methods {} { return {check create destroy new setup} }
proc store-instc-methods {} { return {check clear destroy exists export get getv names set setup setv size unset unsetv} }

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
