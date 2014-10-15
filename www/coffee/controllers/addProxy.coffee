Shark.controller 'AddProxyCtrl', ($scope, Proxies) ->
  $scope.newProxy = {}

  $scope.add = ->
    Proxies.add($scope.newProxy)
    $scope.newProxy = {}
