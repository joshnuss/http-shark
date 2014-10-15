Shark.controller 'TracesCtrl', ($scope, Traces) ->
  $scope.traces = Traces.traces

  $scope.$watch (-> Traces.traces), ->
    $scope.traces = Traces.traces
