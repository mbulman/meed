fb = require('facebook-js') #TODO change if/when pull request is accepted
#fb = require('../facebook-js')
fs = require('fs')
util = require('./util')
winston = require('winston')

TOKEN_FILE = './fbauthtoken'

class Collector
    constructor: (@store) ->

    update: (since, limit) ->
        winston.debug 'Updating Facebook items', { since: since, limit: limit }
        token = getToken()
        if token
            @_getItems token, since, limit, (items) =>
                @store.addItems(@_processItems(items))

    _getItems: (token, since, limit, cb) ->
        items = []
        fetch = (offset) ->
            curr_limit = Math.min(50, limit-items.length)
            fb.apiCall 'GET', '/me/home', {access_token:token, offset:offset, limit:curr_limit}, (err, resp, body) =>
                items = items.concat(body.data)
                if items.length >= limit or body.data.length == 0
                    cb(items)
                else
                    fetch(items.length)
        fetch(0)

    _processItems: (items) ->
        # TODO more info for video (name, description, link to video itself)
        # TODO if no message, should we try to get it from the item directly?
        retval = []

        for item in items
            #winston.debug 'Facebook item', item
            link = null
            switch item.type
                when "status", "link"
                    if item.actions
                        for a in item.actions
                            if a.name is 'Comment'
                                link = a.link
                                break

            if link
                retval.push({
                    type: item.type,
                    created: new Date(item.created_time).getTime(),
                    name: item.from.name,
                    message: item.message,
                })
            # TODO
            #else
                #winston.debug 'Unknown Facebook item', item
        winston.debug 'Storing '+retval.length+' facebook items'
        winston.verbose 'Facebook items', retval
        retval

exports.Collector = Collector

exports.getToken = getToken = ->
    if util.fileExists(TOKEN_FILE)
        return fs.readFileSync(TOKEN_FILE, 'utf8')
