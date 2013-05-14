TODO

	Check the method result requirements for 'tie', and put them
	into the code and tests.


Usable by Tcllib's tie package.

base API
	Simple persistent hash. Tcl array.

		key --> value

	clear:  ()	   --> ()
	exists: key 	   --> boolean
	get:	pattern?   --> list (values)
	getv:	key        --> value
	names:	pattern?   --> list (keys)
	set:	dict	   --> ()
	setv:	key value  --> value
	size:	()   	   --> integer
	unset:	key	   --> ()
	unsetv:	pattern?   --> ()

mtime API.
	Extended persistent hash.
	Maintains a last-modified timestamp per key.

		key -> (mtime, value)
	
	clear:  ()	    	  --> ()
	exists: key 	   	  --> boolean
	get:	pattern?   	  --> list (values)
	gett:	pattern?   	  --> list (mtime)
	gettv:	key	   	  --> mtime
	getv:	key        	  --> value
	names:	pattern?   	  --> list (keys)
	set:	dict	   	  --> ()
	setv:	key value time?   --> value
	size:	()   	   	  --> integer
	unset:	key	   	  --> ()
	unsetv:	pattern?   	  --> ()

multi API.
	Extended persistent hash.

	Maintains multiple hashes per store, using a 2-level key
	scheme, documents and fields.

		(docid, key) --> value

	The main API is operating on the totality of the store,
	document independent.  An integrated backend in the main class
	provides access to individual documents as separate base
	instances, and the standard base API.

	clear:  ()	      --> ()
	exists: doc key	      --> boolean
	get:	doc pattern?  --> list (values)
	getv:	doc key       --> value
	names:	doc pattern?  --> list (keys)
	set:	doc dict      --> ()
	setv:	doc key value --> value
	size:	doc?   	      --> integer
	unset:	doc key	      --> ()
	unsetv:	doc pattern?  --> ()

multitime API
	Combines mtime and multi into a single system.

	Maintains multiple mtime-hashes per store, using a 2-level key
	scheme, documents and fields.

		(docid, key) --> (value, mtime)

	The main API is operating on the totality of the store,
	document independent (equal to multi).  An integrated backend
	in the main class provides access to individual documents as
	separate mtime instances, and the mtime API.

	Use case for multitime is the cached store of (fossil) ticket
	changes, for example. The cache contains the latest (mtime)
	state for all tickets (documents) and their fields (hash key).


base  --> multi
  |         |
  V         V
mtime --> multitime

=========================

listbase
	Extended from base, distinguish scalar and list values.
	Has to keep type information per key.

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
