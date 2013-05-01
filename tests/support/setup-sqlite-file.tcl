## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    global store_path
    set    store_path [file normalize _phash_[pid]_]

    sqlite3              mydb    $store_path
    [store-class] create myphash ::mydb phash
    return
}

proc release-store {} {
    catch { myphash destroy }
    catch { mydb    close   }

    global store_path
    file delete $store_path
    unset store_path
    return
}

# # ## ### ##### ######## ############# #####################
return
