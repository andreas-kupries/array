Usable by Tcllib's tie package.

base API
	Simple persistent hash. Tcl array.

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
	Extended persistent hash. Maintains a last-modified timestamp
	per key.
	
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
	Extended persistent hash. Maintains multiple hashes per store,
	using a 2-level key scheme, documents and fields.

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






phash - Simple persistent hash
	key --> value

phash::mtime - Extended phash storing mtime per key
	key -> (mtime, value)

kphash - multiple independent phashes in a single store.
	(docid, key) --> value

mkphash - Extend kphash, multiple independent phash::mtime in a single store.

	(docid, key) --> (value, mtime)

Use case for mkphash is the cached store of, say ticket changes. The
cache contains the latest (mtime) state for all tickets (documents)
and their fields (hash key).


Check the method result requirements for 'tie', and put them into the
code and tests.
