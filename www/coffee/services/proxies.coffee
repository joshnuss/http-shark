Shark.service 'Proxies', (Socket) ->
  service =
    all: {}

    add: (proxy) ->
      proxy.alias = proxy.alias.toLowerCase()
      Socket.emit('proxy:add', proxy)

    remove: (id) ->
      Socket.emit('proxy:remove', id)
      delete service.list[id]
      service.autoSelect() if service.selected && service.selected._id == id

    update: (proxy) ->
      proxy.alias = proxy.alias.toLowerCase()
      Socket.emit('proxy:update', proxy)

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
    service.all = list

    if !service.selected || !(service.selected._id in Object.keys(service.all))
      service.autoSelect()

  service
