fs = require('fs')
sqlite3 = require('sqlite3').verbose()
util = require('./util')

class Store
    constructor: ->
        @data = []
        # TODO persist to disk
        @db = new sqlite3.Database(':memory:')
        this._setupDb()

    addItems: (items) ->
        s = @db.prepare('INSERT INTO items (type,created,name,message,source) VALUES(?,?,?,?,?)')
        for item in items
            s.run(item.type, item.created, item.name, item.message, item.source)
        s.finalize()

    getItems: (cb) ->
        @db.all 'SELECT * FROM items ORDER BY created DESC', (err, rows) ->
            if err
                throw err
            cb(r for r in rows)

    load: ->
        if util.fileExists(FILE_STORE)
            contents = fs.readFileSync(FILE_STORE, 'utf8')
            @data = JSON.parse(contents)

    _setupDb: ->
        @db.serialize =>
            @db.run("CREATE TABLE items (type, created, name, message, source)")
            @db.run("CREATE INDEX type_idx ON items (type)")
            @db.run("CREATE INDEX created_idx ON items (created)")
            @db.run("CREATE INDEX name_idx ON items (name)")

exports.Store = Store
