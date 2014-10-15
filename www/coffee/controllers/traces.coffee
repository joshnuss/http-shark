Shark.controller 'TracesCtrl', ($scope, Traces) ->
  $scope.traces = Traces.traces
  $scope.pausedTraces = Traces.pausedTraces

  $scope.$watch (-> Traces.traces), ->
    $scope.traces = Traces.traces

  $scope.$watch (-> Traces.pausedTraces), ->
    $scope.pausedTraces = Traces.pausedTraces
