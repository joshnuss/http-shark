express  = require('express')
app      = express()
server   = require('http').Server(app)
io       = require('socket.io')(server)
mappings = {}

server.listen(process.env.PORT || 3000)

app.use('/dash', express.static(__dirname + '/www/compiled'))
app.use('/dash/lib', express.static(__dirname + '/www/lib'))

app.use (request, response) ->
  response.end("test")

io.on 'connection', (socket) ->
  socket.emit('config', mappings)

  broadcastConfig: ->
    socket.broadcast.emit('config', mappings)

  socket.on 'config:add', (config) ->
    mappings[config.alias] = config.url

    broadcastConfig()

  socket.on 'config:update', (data) ->
    delete mappings[data.old.alias]
    mappings[data.new.alias] = data.new.url

    broadcastConfig()

  socket.on 'config:remove', (alias) ->
    delete mappings[alias]
    broadcastConfig()

  socket.on 'requests:monitor', (alias) ->
    true

  socket.on 'requests:pause', (alias) ->
    true

  socket.on 'requests:clear', (data, callback) ->
    true

  socket.on 'requests:remove', (data, callback) ->
    true
