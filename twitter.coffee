twitter = require('ntwitter')
fs = require('fs')
util = require('./util')
store = require('./store')
winston = require('winston')

TOKEN_FILE = './twauthtoken'
CONSUMER_FILE = './twconsumerkey'

class Collector
    constructor: (@store) ->

    update: (since, limit) ->
        winston.debug('Updating Twitter items', { since: since, limit: limit })
        token_file = getFileContents(TOKEN_FILE)
        consumer_file = getFileContents(CONSUMER_FILE)
        if token_file and consumer_file
            parts = token_file.split("\n")
            token = parts[0]
            token_secret = parts[1]

            parts = consumer_file.split("\n")
            consumer_key = parts[0]
            consumer_secret = parts[1]

            twit = new twitter({
                consumer_key: consumer_key,
                consumer_secret: consumer_secret,
                access_token_key: token,
                access_token_secret: token_secret
            })
            twit.get '/statuses/home_timeline.json', {}, (err, data) =>
                items = []
                if err
                    # TODO error handling
                    throw err

                for item in data
                    items.push({
                        type: null,
                        created: new Date(item.created_at).getTime(),
                        name: item.user.name,
                        message: item.text
                    })

                winston.debug('Storing ' + items.length + ' Twitter items')
                winston.verbose('Twitter items', items)
                @store.addItems(items)
                return


exports.Collector = Collector

exports.getFileContents = getFileContents = (file_name) ->
    if util.fileExists(file_name)
        return fs.readFileSync(file_name, 'utf8')

