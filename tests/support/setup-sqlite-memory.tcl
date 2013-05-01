## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    sqlite3              mydb    :memory:
    [store-class] create myphash ::mydb phash
    return
}

proc release-store {} {
    catch { myphash destroy }
    catch { mydb    close   }
    return
}

# # ## ### ##### ######## ############# #####################
return
