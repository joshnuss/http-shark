Shark.service 'Proxies', (Socket) ->
  service =
    all: {}

    add: (proxy) ->
      Socket.emit('proxy:add', proxy)

    remove: (alias) ->
      Socket.emit('proxy:remove', alias)

    update: (alias, proxy) ->
      Socket.emit('proxy:update', {old: {alias: alias}, new: proxy})

    selected: null
    paused: false

    pause: (alias) ->
      service.paused = true

    select: (alias) ->
      service.selected = alias
      service.paused = false
      Socket.emit('proxy:monitor', alias)

  Socket.on 'proxy:list', (list) ->
    service.all = list

    keys = Object.keys(list)

    if !service.selected && keys.length > 0
      service.select(keys[0])

  service
