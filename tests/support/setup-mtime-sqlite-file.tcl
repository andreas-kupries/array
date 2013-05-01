## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    global store_path
    set    store_path [file normalize _phash_[pid]_]
    sqlite3 mydb $store_path
    return [phash::mtime::sqlite create mtime ::mydb phash]
}

proc release-store {} {
    global store_path
    catch { mtime destroy }
    catch { mydb    close }
    file delete $store_path
    unset store_path
    return
}

# # ## ### ##### ######## ############# #####################
return
