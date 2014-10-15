Shark.service 'Traces', (Socket, Proxies) ->
  service =
    traces: []
    pausedTraces: []

    remove: (trace) ->
      Socket.emit('trace:remove', trace)

  Socket.on 'trace:add', (trace) ->
    service.traces.unshift(trace)

  Socket.on 'trace:list', (traces) ->
    service.traces = traces

  Socket.on 'trace:remove', (trace) ->
    true

  Socket.on 'proxy:clear', ->
    service.traces = []
    service.pausedTraces = []

  service
