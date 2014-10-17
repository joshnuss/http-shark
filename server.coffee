express   = require('express')
app       = express()
server    = require('http').Server(app)
io        = require('socket.io')(server)
httpProxy = require('http-proxy').createProxyServer()
url       = require('url')
mongodb   = require('mongodb')
proxies   = {}
sockets   = []

server.listen(process.env.PORT || 3000)

throw "Missing MONGO_URL environment variable" unless process.env.MONGO_URL

mongo = (callback) ->
    mongodb.MongoClient.connect process.env.MONGO_URL, (err, db) ->
      throw err if err

      store =
        collection: (name, callback) ->
          db.collection name, (err, collection) ->
            throw err if err
            callback(collection)

        proxies: (callback) ->
          store.collection("proxies", callback)

        proxyList: (callback) ->
          store.proxies (collection) ->
            collection.find().toArray (err, proxies) ->
              throw err if err
              callback(proxies)

        findProxyByAlias: (alias, callback) ->
          store.proxies (collection) ->
            collection.findOne {alias: alias}, (err, proxy) ->
              if err
                callback(null)
              else
                callback(proxy)

        insertProxy: (proxy, callback) ->
          store.proxies (collection) ->
            collection.insert proxy, (err, results) ->
              callback(results[0])

        updateProxy: (proxy, callback) ->
          store.proxies (collection) ->
            collection.save proxy, (err, result) ->
              callback(proxy)

        removeProxy: (id, callback) ->
          store.proxies (collection) ->
            collection.remove({_id: mongodb.ObjectID(id)}, callback)

        insertTrace: (subdomain, trace, callback) ->
          store.collection "subdomain.#{subdomain}", (collection) ->
            collection.insert trace, (err, result) ->
              callback(result[0])

      callback(store)

mongo (db) ->

  db.proxyList (list) ->
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

      trace =
        at: new Date().getTime()
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

      db.insertTrace subdomain, trace, (result) ->
        sockets.forEach (socket) ->
          socket.emit('trace:add', result) if socket.alias == subdomain

  app.use('/dash', express.static(__dirname + '/www/compiled'))
  app.use('/dash/lib', express.static(__dirname + '/www/lib'))

  app.use (request, response) ->
    host = request.headers.host
    subdomain = host.split('.')[0]

    db.findProxyByAlias subdomain, (proxy) ->
      if !proxy
        response.writeHead(404)
        response.end("Mapping for #{host}#{request.url} not found.\n")
        console.log("ERROR: Mapping for #{host}#{request.url} not found.")
      else
        targetDomain = proxy.url
        targetUrl = targetDomain + url.parse(request.url).path

        console.log("PROXY: from #{host}#{request.url} to #{targetUrl}")

        request.url = targetUrl

        httpProxy.web(request, response, {target: targetDomain})

  io.on 'connection', (socket) ->
    sockets.push(socket)

    socket.emit('proxy:list', proxies)

    broadcastConfig = ->
      socket.emit('proxy:list', proxies)
      socket.broadcast.emit('proxy:list', proxies)

    socket.on 'proxy:add', (proxy) ->
      db.insertProxy proxy, (result) ->
        proxies[result._id] = result

        broadcastConfig()

    socket.on 'proxy:update', (proxy) ->
      db.updateProxy proxy, (result) ->
        delete proxies[proxy.id]
        proxies[result._id] = result

        broadcastConfig()

    socket.on 'proxy:remove', (id) ->
      db.removeProxy id, ->
        delete proxies[id]
        broadcastConfig()

    socket.on 'proxy:monitor', (alias) ->
      socket.alias = alias

    socket.on 'trace:clear', ->
      true

    socket.on 'trace:remove', (id, callback) ->
      true

    socket.on 'disconnected', ->
      delete sockets[sockets.indexOf(socket)]
