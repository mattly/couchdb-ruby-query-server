# CouchDB Ruby Query Server

by Matthew Lyon <matt@flowerpowered.com>

This is a ruby version of the CouchDB Query server. It will let you write your map and reduce functions in ruby (instead of javascript, erlang, or what have you) and eventually all your couchapp functions as well.

It is still very much a work in progress, please don't use it for anything in production yet. 

## Usage

In one of your CouchDB config files, add this:

    [query_servers]
    ruby = /path/to/ruby /path/to/bin/couchdb_view_server

If you want to just use environment ruby you can leave /path/to/ruby out.

Your design documents should look something like this:

    {
        "_id": "_design/foos",
        "language": "ruby",
        "views": {
            "foos": {
                "map": "lambda{|doc| emit(doc['foo'], nil) }"
            }
        }
    }

## Notes

Does not yet run on Ruby 1.8.6, as it requires `instance_exec`. Will most likely just steal Rails' implementation.

## TODO

* handle edge cases for map/reduce that aren't covered by the couchdb view server spec but indicated in the javascript view query server code.
* Better Error Handling (for syntax errors, etc)
* Document Management Functions (update, validation)
* Streaming Update Functions (filter)
* Templating Functions (show, list)

## Changelog

### 0.1 2010-03-14
* Offer a "safe" flag to provide a locked-down sandbox for user code inside $SAFE level 4.

### 0.1pre 2 2010-03-13
* Consolidate a lot of the "in-place, get it working" code for map/reduce to the View module.

### 0.1pre 1 2010-03-07
* Basic implementation of map/reduce working.