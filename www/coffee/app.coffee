window.Shark = angular.module('shark', ['ngRoute', 'btford.socket-io'])

Shark.config ($routeProvider) ->
  $routeProvider
    .when '/proxies',
      controller: 'ProxiesCtrl'
      templateUrl: 'views/proxies/index.html'

    .when '/proxies/add',
      controller: 'AddProxyCtrl'
      templateUrl: 'views/proxies/add.html'

    .when '/proxies/update/:proxyId',
      controller: 'UpdateProxyCtrl'
      templateUrl: 'views/proxies/update.html'

    .when '/trace',
      controller: 'TracesCtrl'
      templateUrl: 'views/traces.html'

    .otherwise
      redirectTo: '/proxies'
