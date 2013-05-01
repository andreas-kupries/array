## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    sqlite3 mydb :memory:
    return [phash::sqlite create myphash ::mydb phash]
}

proc release-store {} {
    catch { myphash destroy }
    catch { mydb    close   }
    return
}

# # ## ### ##### ######## ############# #####################
return
