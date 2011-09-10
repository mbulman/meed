express = require('express')
facebook = require('./facebook')
store = require('./store')

stored_pos = 0 # TODO persist

post_store = new store.Store

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
    res.send(post_store.getItems())

app.get '/pos', (req, res) ->
    console.debug("Sending stored position:", stored_pos)
    res.send(""+stored_pos)

app.put '/pos', (req, res) ->
    console.debug("Saving position:", req.body)
    stored_pos = req.body

app.listen(3000)
