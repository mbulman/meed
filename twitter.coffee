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
            console.log(token)
            console.log(token_secret)
            ###
            twitter.apiCall 'GET', '/statuses/home_timeline.json', {token: {oauth_token_secret: token_secret, oauth_token: token}}, (error, result) ->
                    console.log(error, result)
            return
            ###
            twit = new twitter({
                consumer_key: 'NmbnSBsbGfER6nYuoe7aWw',
                consumer_secret: 'fiZriZSswj6H3gQZolgwB0ct0mHDFpOilo0sUUdEQ',
                access_token_key: token,
                access_token_secret: token_secret
            })
            twit.get '/statuses/home_timeline.json', {}, (err, data) =>
                items = []
                console.log(err)
                console.log(data)
                if err
                    return

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

t = new Collector(new store.Store)
t.update()
