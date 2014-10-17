Shark.controller 'ProxiesCtrl', ($scope, Proxies, $location) ->
  $scope.proxies = {}
  $scope.paused = false

  parts = window.location.hostname.split('.')

  if parts.length > 2
    parts = parts.slice(1)

  $scope.host = parts.join(".")

  $scope.$watch (-> Proxies.all), ->
    $scope.proxies = Proxies.all

  $scope.$watch (-> Proxies.selected), ->
    $scope.selected = Proxies.selected

  $scope.$watch (-> Proxies.paused), ->
    $scope.paused = Proxies.paused

  $scope.togglePaused = ->
    Proxies.paused = !Proxies.paused
    $location.path("/trace") if !Proxies.paused

  $scope.pause = ->
    Proxies.paused = true

  $scope.select = (proxy) ->
    Proxies.select(proxy._id)
    $location.path("/trace")

  $scope.remove = (proxy) ->
    if confirm("Are you sure you want to remove #{proxy.alias}?")
      Proxies.remove(proxy._id)
