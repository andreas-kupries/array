## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc already {cmd} {
    return "can't create object \"$cmd\": command already exists with that name"
}

proc badmethod {m real} {
    set real [lsort -dict $real]
    set real [string map {{, or} { or}} [linsert [join $real {, }] end-1 or]]
    return "unknown method \"$m\": must be $real"
}

# # ## ### ##### ######## ############# #####################

proc class-methods {} { return {create new destroy} }

proc core-instc-methods  {} { return {clear destroy exists export get getv names set setv size unset unsetv value} }
proc multi-instc-methods {} { return {clear destroy export get getv keys names open size unset unsetv} }
proc time-instc-methods  {} { return {get-time get-timev set-timev} }
proc list-instc-methods  {} { return {append remove} }
proc sqlite-methods      {} { return {check setup} }

proc U {args} {
    foreach s $args { lappend result {*}$s }
    return $result
}

# # ## ### ##### ######## ############# #####################
