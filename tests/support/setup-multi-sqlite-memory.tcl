## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc store-class {} { lindex [split [test-class] /] 0 }

proc new-store {} {
    sqlite3              mydb    :memory:
    [store-class] create mymulti ::mydb phash
    rename [mymulti open ABC] myphash
    rename [mymulti open XYZ] mydoc
    return
}

proc release-store {} {
    catch { myphash destroy }
    catch { mydoc   destroy }
    catch { mymulti destroy }
    catch { mydb    close   }
    return
}

# # ## ### ##### ######## ############# #####################
return
