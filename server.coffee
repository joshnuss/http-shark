express = require('express')
app     = express()
server  = require('http').Server(app)
io      = require('socket.io')(server)
proxies = {}
traces  = {}
sockets = []

server.listen(process.env.PORT || 3000)

app.use('/dash', express.static(__dirname + '/www/compiled'))
app.use('/dash/lib', express.static(__dirname + '/www/lib'))

app.use (request, response) ->
  alias = 'weather'
  traces[alias] || = []

  trace =
    at: (new Date()).getTime()
    request:
      method: request.method
      ip: request.connection.removeAddress
      url: request.url
      headers: request.headers
      body: '<empty>'
    response:
      code: 200
      headers: request.headers
      body: '<empty>'

  traces[alias].push(trace)

  sockets.forEach (socket) ->
    socket.emit('trace:add', trace) if socket.alias == alias

  response.end("test")

# remove me
#proxies['weather'] = 'http://api.openweathermap.org'
#proxies['google'] = 'http://api.google.com'

io.on 'connection', (socket) ->
  sockets.push(socket)
  socket.emit('proxy:list', proxies)

  broadcastConfig = ->
    socket.emit('proxy:list', proxies)
    socket.broadcast.emit('proxy:list', proxies)

  socket.on 'proxy:add', (proxy) ->
    proxies[proxy.alias] = proxy.url

    broadcastConfig()

  socket.on 'proxy:update', (data) ->
    delete proxies[data.old.alias]
    proxies[data.new.alias] = data.new.url

    sockets.forEach (socket) ->
      socket.alias = data.new.alias if socket.alias == data.old.alias

    broadcastConfig()

  socket.on 'proxy:remove', (alias) ->
    delete proxies[alias]
    broadcastConfig()

  socket.on 'proxy:monitor', (alias) ->
    socket.alias = alias

  socket.on 'trace:clear', (data, callback) ->
    true

  socket.on 'trace:remove', (data, callback) ->
    true

  socket.on 'disconnected', ->
    sockets.splice(sockets.indexOf(socket), 1)
