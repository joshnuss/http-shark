express   = require('express')
app       = express()
server    = require('http').Server(app)
io        = require('socket.io')(server)
httpProxy = require('http-proxy').createProxyServer()
url       = require('url')
mongo     = require('mongodb')
client    = mongo.MongoClient
proxies   = {}
traces    = {}
sockets   = []

server.listen(process.env.PORT || 3000)

throw "Missing MONGO_URL environment variable" unless process.env.MONGO_URL

client.connect process.env.MONGO_URL, (err, db) ->
  throw err if err

  withProxyCollection = (callback) ->
    db.collection 'proxies', (err, collection) ->
      throw err if err
      callback(collection)

  withProxyList = (callback) ->
    withProxyCollection (collection) ->
      collection.find().toArray (err, proxies) ->
        throw err if err
        callback(proxies)

  withProxyList (list) ->
    list.forEach (proxy) ->
      proxies[proxy._id] = proxy

  httpProxy.on 'error', (e, request, response) ->
    response.writeHead(500)
    response.end("Problem with request: #{e.message}")

  httpProxy.on 'proxyRes', (proxyResponse, request, response) ->
    body = ''
    requestBody = ''

    subdomain = request.headers.host.split('.')[0]

    request.on 'data', (chunk) ->
      requestBody += chunk

    proxyResponse.on 'data', (chunk) ->
      body += chunk

    proxyResponse.on 'end', ->
      console.log("RESPONSE: #{proxyResponse.statusCode}")
      time = new Date().getTime()

      trace =
        at: time
        request:
          ip: request.connection.remoteAddress
          url: request.url
          method: request.method
          headers: request.headers
          body: requestBody
        response:
          code: proxyResponse.statusCode
          headers: proxyResponse.headers
          body: body

      traces[subdomain] ||= []
      traces[subdomain].push(trace)

      db.collection "subdomain.#{subdomain}", (err, collection) ->
        collection.insert trace, (err, result) ->
          sockets.forEach (socket) ->
            socket.emit('trace:add', result[0]) if socket.alias == subdomain

  app.use('/dash', express.static(__dirname + '/www/compiled'))
  app.use('/dash/lib', express.static(__dirname + '/www/lib'))

  app.use (request, response) ->
    host = request.headers.host
    subdomain = host.split('.')[0]

    withProxyCollection (collection) ->
      collection.findOne {alias: subdomain}, (err, proxy) ->
        if err
          response.writeHead(404)
          response.end("Mapping for #{host}#{request.url} not found.\n")
          console.log("ERROR: Mapping for #{host}#{request.url} not found.")
        else
          targetDomain = proxy.url
          targetUrl = targetDomain + url.parse(request.url).path

          console.log("PROXY: from #{request.headers.host}#{request.url} to #{targetUrl}")

          request.url = targetUrl

          httpProxy.web(request, response, {target: targetDomain})

  io.on 'connection', (socket) ->
    sockets.push(socket)

    socket.emit('proxy:list', proxies)

    broadcastConfig = ->
      socket.emit('proxy:list', proxies)
      socket.broadcast.emit('proxy:list', proxies)

    socket.on 'proxy:add', (proxy) ->
      withProxyCollection (collection) ->
        collection.insert proxy, (err, results) ->
          result = results[0]
          proxies[result._id] = result

          broadcastConfig()

    socket.on 'proxy:update', (proxy) ->
      delete proxies[proxy.id]
      proxies[proxy.id] = proxy

      broadcastConfig()

    socket.on 'proxy:remove', (id) ->
      withProxyCollection (collection) ->
        collection.remove {_id: mongo.ObjectID(id)}, (err, results) ->
          delete proxies[id]
          broadcastConfig()

    socket.on 'proxy:monitor', (alias) ->
      socket.alias = alias

    socket.on 'trace:clear', (data, callback) ->
      true

    socket.on 'trace:remove', (data, callback) ->
      true

    socket.on 'disconnected', ->
      delete sockets[sockets.indexOf(socket)]
