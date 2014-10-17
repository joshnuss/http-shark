Shark.controller 'AddProxyCtrl', ($scope, Proxies, $location) ->
  $scope.newProxy = {}

  $scope.add = ->
    Proxies.add($scope.newProxy)

    $location.path("/proxies")
