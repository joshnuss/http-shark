Shark.controller 'UpdateProxyCtrl', ($scope, Proxies, $routeParams, $location) ->
  $scope.$watch (-> Proxies.all), ->
    $scope.proxy = angular.copy(Proxies.all[$routeParams.proxyId])
    $scope.alias = $scope.proxy.alias if $scope.proxy

  $scope.update = ->
    Proxies.update($scope.proxy)

    $location.path("/dash/#/proxies")
