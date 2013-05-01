## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    sqlite3 mydb :memory:
    return [phash::mtime::sqlite create mtime ::mydb phash]
}

proc release-store {} {
    catch { mtime destroy }
    catch { mydb    close }
    return
}

# # ## ### ##### ######## ############# #####################
return
