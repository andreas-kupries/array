Usable by Tcllib's tie package.

base API
	Simple persistent hash. Tcl array.

	clear:  ()	   --> ()
	exists: key 	   --> boolean
	get:	pattern?   --> list (values)
	getv:	key        --> value
	names:	pattern?   --> list (keys)
	set:	dict	   --> ()
	setv:	key, value --> value
	size:	()   	   --> integer
	unset:	key	   --> ()
	unsetv:	pattern?   --> ()

mtime API.
	Extended persistent hash. Maintains
	a last-modified timestamp per key.
	
	clear:  ()	    	  --> ()
	exists: key 	   	  --> boolean
	get:	pattern?   	  --> list (values)
	gett:	pattern?   	  --> list (mtime)
	gettv:	key	   	  --> mtime
	getv:	key        	  --> value
	names:	pattern?   	  --> list (keys)
	set:	dict	   	  --> ()
	setv:	key, value, time? --> value
	size:	()   	   	  --> integer
	unset:	key	   	  --> ()
	unsetv:	pattern?   	  --> ()




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
