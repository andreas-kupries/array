## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################
kt source multi-support.tcl

proc new-store {} {
    global store_path
    set    store_path [file normalize _phash_[pid]_]
    sqlite3 mydb $store_path
    phash::multi::sqlite create mymulti ::mydb phash
    rename [mymulti open ABC] myphash
    rename [mymulti open XYZ] mydoc
    return myphash
}

proc release-store {} {
    global store_path
    catch { myphash destroy }
    catch { mydoc   destroy }
    catch { mymulti destroy }
    catch { mydb    close }
    file delete $store_path
    unset store_path
    return
}

# # ## ### ##### ######## ############# #####################
return
