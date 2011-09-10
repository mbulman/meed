fs = require('fs')
util = require('./util')

FILE_STORE = './db.json'

class Store
    constructor: ->
        @data = []

    addItems: (items) ->
        @data = @data.concat(items)
        #TODO persist to disk
        return

    getItems: ->
        @data

    load: ->
        if util.fileExists(FILE_STORE)
            contents = fs.readFileSync(FILE_STORE, 'utf8')
            @data = JSON.parse(contents)

exports.Store = Store
