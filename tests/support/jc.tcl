## -*- tcl -*-
## (c) 2013 Andreas Kupries
# # ## ### ##### ######## ############# #####################

proc jcsave {i a} {
    variable jc [list [json::write::indented] [json::write::aligned]]
    json::write::indented $i
    json::write::aligned  $a
    return
}

proc jcrestore {} {
    variable jc
    lassign $jc i a
    json::write::indented $i
    json::write::aligned  $a
    unset jc
    return
}

# # ## ### ##### ######## ############# #####################
