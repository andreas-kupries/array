## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    global store_path
    set    store_path [file normalize _phash_[pid]_]

    sqlite3              mydb    $store_path
    [store-class] create mymulti ::mydb phash
    rename [mymulti open ABC] myphash
    rename [mymulti open XYZ] mydoc
    return myphash
}

proc release-store {} {
    catch { myphash destroy }
    catch { mydoc   destroy }
    catch { mymulti destroy }
    catch { mydb    close   }

    global store_path
    file delete $store_path
    unset store_path
    return
}

# # ## ### ##### ######## ############# #####################
return
