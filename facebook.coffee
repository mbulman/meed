#fb = require('facebook-js') TODO change if/when pull request is accepted
fb = require('../facebook-js')
fs = require('fs')
util = require('./util')

TOKEN_FILE = './fbauthtoken'

class Collector
    constructor: (@store) ->

    update: (since, limit) ->
        token = getToken()
        if token
            fb.apiCall 'GET', '/me/home', {access_token:token}, (err, resp, body) =>
                items = []
                # TODO more info for video (name, description, link to video itself)
                # TODO if no message, should we try to get it from the item directly?
                for item in body.data
                    console.log(item)
                    link = null
                    switch item.type
                        when "status", "link"
                            if item.actions
                                for a in item.actions
                                    if a.name is 'Comment'
                                        link = a.link
                                        break

                    if link
                        items.push({
                            type: item.type,
                            created: new Date(item.created_time).getTime(),
                            name: item.from.name,
                            message: item.message,
                        })
                    else
                        console.log("Unknown fb item:", item)
                @store.addItems(items)
                return

exports.Collector = Collector

exports.getToken = getToken = ->
    if util.fileExists(TOKEN_FILE)
        return fs.readFileSync(TOKEN_FILE, 'utf8')
