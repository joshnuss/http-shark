Shark.controller 'TracesCtrl', ($scope, Proxies, Traces) ->
  $scope.traces = Traces.traces
  $scope.pausedTraces = Traces.pausedTraces

  $scope.host = Proxies.host()

  $scope.$watch (-> Proxies.selected), ->
    $scope.proxy = Proxies.selected

  $scope.$watch (-> Traces.traces), ->
    $scope.traces = Traces.traces

  $scope.$watch (-> Traces.pausedTraces), ->
    $scope.pausedTraces = Traces.pausedTraces

  $scope.statusClass = (trace) ->
    code = trace.response.code
    if code >= 500
      'error'
    else if code >= 400
      'warning'
    else if code >= 300
      'info'
    else if code >= 200
      'success'
