TODO

        Check the method result requirements for 'tie', and put them
        into the code and tests.


Usable by Tcllib's tie package.

base API
        Simple persistent hash. Tcl array.

                key --> value

        size:   ()         --> integer
        names:  ?pattern?  --> list (keys)
        exists: key        --> boolean

        get:    ?pattern?  --> dict (key --> value)
        getv:   key        --> value

        set:    dict       --> ()
        setv:   key value  --> value

        unset:  ?pattern?  --> ()
        unsetv: key        --> ()
        clear:  ()         --> ()

	Query data by value (glob).
	Return the dictionary for matching values.

        value: ?pattern?  --> dict (key --> value)

	Alternate names for various methods?

		regsub getv   get1   get_value
		regsub setv   set1   set_value
		regsub unsetv unset1 unset_value

mtime API.
        Extended persistent hash.
        Maintains a last-modified timestamp per key.

                key --> (mtime, value)

	alt	key --> mtime
		key --> value

        size:   ()                --> integer
        names:  ?pattern?         --> list (keys)
        exists: key               --> boolean
        
        get:    ?pattern?         --> dict (key --> value)
        getv:   key               --> value

        set:    dict              --> ()
**      setv:   key value ?time?  --> value

        unset:  ?pattern?         --> ()
        unsetv: key               --> ()
        clear:  ()                --> ()

**      get-time:   ?pattern?     --> dict (key --> mtime)
**      get-timev:  key           --> mtime
**      set-timev:  key time      --> time

	Future: after x, before x, between x y
	Future: not-after x, not-before x, not-between x y

        (Queries based on time: older than, younger than?)
                (Index: mtime --> list (key)

multi API.
        Extended persistent hash.

        Maintains multiple hashes per store, using a 2-level key
        scheme, documents and fields.

                (docid, key) --> value

        The main API is operating on the totality of the store,
        document independent.

	size:	()	  --> integer		(#documents)
	names:	?pattern? --> list (string)	(matching doc names)
	keys:	?pattern? --> list (string)	(matching key names across all documents)

	get:    ?pattern? --> dict (key --> (doc --> value))
	getv:   key       --> dict (doc --> value)

	unset:  ?pattern? --> ()	     (remove matchng keys in all documents)
	unsetv: key       --> ()	     (remove key in all documents)
	clear:  ()        --> ()	     (remove all keys and documents)

	An integrated backend in the main class provides access to
        individual documents as separate base instances, and its
        standard base API.

        size:   doc            --> integer
        names:  doc ?pattern?  --> list (keys)
        exists: doc key        --> boolean

        get:    doc ?pattern?  --> dict (key --> value)
        getv:   doc key        --> value

        set:    doc dict       --> ()
        setv:   doc key value  --> value

        unset:  doc ?pattern?  --> ()
        unsetv: doc key        --> ()
        clear:  ()             --> ()

multitime API
        Combines mtime and multi into a single system.

        Maintains multiple mtime-hashes per store, using a 2-level key
        scheme, documents and fields.

                (docid, key) --> (value, mtime)

        The main API is operating on the totality of the store,
        document independent (equal to multi).  An integrated backend
        in the main class provides access to individual documents as
        separate mtime instances, and its mtime API.

        Use case for multitime is the cached store of (fossil) ticket
        changes, for example. The cache contains the latest (mtime)
        state for all tickets (documents) and their fields (hash key).


base  --> multi
  |         |
  V         V
mtime --> multitime

=========================

listbase
        Extended from base, treat all values as lists. Scalars are
        just a list containing a single element.

                key --> list (value)
        
        clear:  ()                --> ()
        exists: key               --> boolean
        get:    ?pattern?         --> dict (key --> list (value))
        getv:   key               --> list (value)
        names:  ?pattern?         --> list (keys)
        set:    dict              --> ()
        setv:   key value...      --> value...
	append:	key value...      --> value...
	remove: key value...	  --> ()
        size:   ()                --> integer
        unset:  key               --> ()
        unsetv: ?pattern?         --> ()

Methods to query by value.


listmulti
        multi on top of listbase

listmtime
        mtime on top of listbase

listmultitime
        multitime on top of listbase

        Use case: Ticket changes, where fields can be lists, and list
        elements should be individually accessible, searchable.

        (Alternate example: Catalog for a library. Author field of
        each catalog entry is a list, title field of same entry is
        not).
