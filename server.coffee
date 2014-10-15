express = require('express')
app = express()
server = require('http').Server(app)
io = require('socket.io')(server)

server.listen(process.env.PORT || 3000)

app.use('/dash', express.static(__dirname + '/www'))

mappings = []

io.on 'connection', (socket) ->
  console.log 'user connected'

  socket.on 'configs:list', (data, callback) ->
    true

  socket.on 'configs:add', (config, callback) ->
    true

  socket.on 'configs:update', (config, callback) ->
    true

  socket.on 'configs:remove', (config, callback) ->
    true

  socket.on 'requests:clear', (data, callback) ->
    true

  socket.on 'requests:remove', (data, callback) ->
    true
