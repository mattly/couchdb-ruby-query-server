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

* Better Error Handling (for syntax errors, etc)
* optional/default $SAFEing of the eval/run process, because user code can be scary.
* Document Management Functions (update, validation)
* Streaming Update Functions (filter)
* Templating Functions (show, list)