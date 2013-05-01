## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc new-store {} {
    sqlite3 mydb :memory:
    phash::multi::sqlite create mymulti ::mydb phash
    rename [mymulti open ABC] myphash
    rename [mymulti open XYZ] mydoc
    return myphash
}

proc release-store {} {
    catch { myphash destroy }
    catch { mydoc   destroy }
    catch { mymulti destroy }
    catch { mydb    close }
    return
}

# # ## ### ##### ######## ############# #####################
return
