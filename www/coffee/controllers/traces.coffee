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
