express = require('express')
winston = require('winston')

facebook = require('./facebook')
twitter = require('./twitter')
store = require('./store')

stored_pos = 0 # TODO persist

post_store = new store.Store

fb_collector = new facebook.Collector(post_store)
fb_collector.update('', 200)

(new twitter.Collector(post_store)).update('', 200)

if false
    testdata = []
    for i in [50..0]
        testdata.push({
            type: 'status',
            created: (new Date().getTime()) - (i*60000),
            name: 'John Doe' + (50-i),
            message: 'This is a long message to test stuff and hopefully this wraps and such'
        })
    post_store.addItems(testdata)

app = express.createServer()
app.use(express.bodyParser())
app.use(express.static(__dirname + '/'))

app.get '/items', (req, res) ->
    post_store.getItems (items) ->
        res.send(items)

app.get '/pos', (req, res) ->
    winston.info 'Sending stored position', stored_pos
    res.send(""+stored_pos)

app.put '/pos', (req, res) ->
    winston.info 'Saving position', { position: req.body }
    stored_pos = req.body

app.listen(3000)
