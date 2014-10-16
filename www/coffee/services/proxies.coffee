Shark.service 'Proxies', (Socket) ->
  service =
    all: {}

    add: (proxy) ->
      Socket.emit('proxy:add', proxy)

    remove: (alias) ->
      Socket.emit('proxy:remove', alias)
      delete service.list[alias]
      service.autoSelect() if service.selected == alias

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

    autoSelect: ->
      keys = Object.keys(service.list)

      if keys.length > 0
        service.select(keys[0])
      else
        service.selected = null

  Socket.on 'proxy:list', (list) ->
    service.all = list
    service.autoSelect() unless service.selected in Object.keys(list)

  service
