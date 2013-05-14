## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc dict2sort {dict} {
    # sorting a 2-level nested dict, in both levels.
    dict for {k v} $dict {
	dict set dict $k [kt dictsort $v]
    }
    kt dictsort $dict
}

# # ## ### ##### ######## ############# #####################
