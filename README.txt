Usable by Tcllib's tie package.

phash - Simple persistent hash
	key --> value

mphash - Extended phash storing mtime per key
	key -> (mtime, value)

kphash - multiple independent phashes in a single store.
	(docid, key) --> value

mkphash - Extend kphash, multiple independent mphashes in a single store.

	(docid, key) --> (value, mtime)

Use case for mkphash is the cached store of, say ticket changes. The
cache contains the latest (mtime) state for all tickets (documents)
and their fields (hash key).
