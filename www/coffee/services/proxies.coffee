Shark.service 'Proxies', (Socket) ->
  service =
    all: {}

    add: (proxy) ->
      Socket.emit('proxy:add', proxy)

    remove: (id) ->
      Socket.emit('proxy:remove', id)
      delete service.list[id]
      service.autoSelect() if service.selected && service.selected.id == id

    update: (alias, proxy) ->
      Socket.emit('proxy:update', {old: {alias: alias}, new: proxy})

    selected: null
    paused: false

    pause: ->
      service.paused = true

    select: (id) ->
      service.selected = service.all[id]
      service.paused = false
      Socket.emit('proxy:monitor', service.selected.alias)

    autoSelect: ->
      ids = Object.keys(service.all)

      if ids.length > 0
        service.select(ids[0])
      else
        service.selected = null

  Socket.on 'proxy:list', (list) ->
    service.all = {}

    list.forEach (proxy) ->
      service.all[proxy._id] = proxy

    if !service.selected || !(service.selected.id in Object.keys(service.all))
      service.autoSelect()

  service
