twitter = require('ntwitter')
fs = require('fs')
util = require('./util')
store = require('./store')

TOKEN_FILE = './twauthtoken'

class Collector
    constructor: (@store) ->

    update: (since, limit) ->
        token_file = getToken()
        if token_file
            parts = token_file.split("\n")
            token = parts[0]
            token_secret = parts[1]
            twit = new twitter({
                consumer_key: 'NmbnSBsbGfER6nYuoe7aWw',
                consumer_secret: 'fiZriZSswj6H3gQZolgwB0ct0mHDFpOilo0sUUdEQ',
                access_token_key: token,
                access_token_secret: token_secret
            })
            twit.get '/statuses/home_timeline.json', {}, (err, data) =>
                items = []
                if err
                    return # TODO Error handling

                for item in data
                    console.log(item)
                    items.push({
                        created: item.created_at,
                        name: item.user.name,
                        message: item.text
                    })

                @store.addItems(items)
                return


exports.Collector = Collector

exports.getToken = getToken = ->
    if util.fileExists(TOKEN_FILE)
        return fs.readFileSync(TOKEN_FILE, 'utf8')

