'use strict'

angular.module 'bcd', [
  'http-auth-interceptor'
  # 'ngCookies'
  'ngStorage'
  'ngSanitize'
  'ngAnimate'
  'ui.router'
  'monospaced.elastic'
  'mgcrea.ngStrap.popover'
  'siger.dialog'
  'agGrid'
  'checklist-model'
  'ui.bootstrap'
  'ui.bootstrap.tpls'
  'ui-notification'
]

angular.module 'bcd'
  .constant 'Acl',
    roles: [
      'anon'
      'patient'
      'doctor'
      'admin'
      'case_manager'
    ]
    access:
      'public':  '*'
      'anon':    ['anon']
      'private': ['patient', 'doctor', 'admin', 'case_manager']
      'patient': ['patient']
      'doctor':  ['doctor', 'admin', 'case_manager']
      'head':    ['doctor', 'admin']
      'admin':   ['admin']
    anonRole: 'anon'

angular.module 'bcd'
  .config ($locationProvider, $httpProvider, $dialogProvider, NotificationProvider) ->
    $locationProvider.hashPrefix "!"
    $locationProvider.html5Mode false
    # $locationProvider.html5Mode true

    $httpProvider.interceptors.push (AuthSession) ->
      request: (config) ->
        token = AuthSession.user().token
        config.headers["Authorization"] = "Token token=#{token}" if token
        config

    angular.extend $dialogProvider.defaults,
      autoOpen: true
      modal: true
      draggable: false
      resizable: false
      closeOnEscape: false
      dialogClass: 'dialog'
      appendTo: '.dialog-container'
      show: {effect: 'fade', duration: 250}
      hide: {effect: 'fade', duration: 250}

    NotificationProvider.setOptions
      delay: 10000,
      startTop: 70,
      startRight: 10,
      verticalSpacing: 20,
      horizontalSpacing: 20,
      positionX: 'right',
      positionY: 'top'


angular.module 'bcd'
  .run ($rootScope, $state, $http, AuthSession, ActivePatient, $window, $location) ->

    $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
      # log '1------'
      # log '$stateChangeStart fromState', fromState
      # log '$stateChangeStart toState', toState

      # fix home when html5Mode is false
      if toState.name is '404' and $location.path() is ""
        $location.path('/').replace();
        return

      # redirect to each role's own home state
      if toState.name is 'home' and AuthSession.isLoggedIn()
        # log "redirect to each role's own home"
        event.preventDefault()
        $state.go AuthSession.homeState()
        return

      # check permissions for logged-in users
      if AuthSession.isLoggedIn() and not AuthSession.authorize(toState.data.access)
        # log "check permissions: user logged-in but has NO ACCESS, redirect to home"
        event.preventDefault()
        $state.go AuthSession.homeState()
        return

      # check permissions for anon users
      if not AuthSession.isLoggedIn() and not AuthSession.authorize(toState.data.access)
        # log "check permissions: user is anon and has NO ACCESS, show login form"
        event.preventDefault()
        $rootScope.showLogin = true
        $rootScope.nextState = state: toState, params: toParams
        # log "next state: ", $rootScope.nextState
        return

      # log "check permissions: OK"

      # show login on anon home page
      if toState.name is 'home' and not AuthSession.isLoggedIn()
        # log "anon user on home page, SHOW LOGIN FORM"
        # event.preventDefault()
        $rootScope.showLogin = true
        $rootScope.nextState = state: toState, params: toParams
        # log "next state: ", $rootScope.nextState
        # return

      # log '------1'

    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      $rootScope.showLogin = false unless toState.name is 'home'
      $rootScope.loginForm = {}

      # log '2------'
      # log "$stateChangeSuccess fromState: ", fromState
      # log "$stateChangeSuccess toState: ", toState

      $rootScope.previousState = state: fromState, params: fromParams
      $rootScope.currentState = state: $state.current, params: $state.params

      # log "previous state: ", $rootScope.previousState.state
      # log "current state: ", $rootScope.currentState.state
      # log "next state: ", $rootScope.nextState.state
      # log '------2'
      $(window).scrollTop(0)

    # $rootScope.$on '$stateNotFound', (event, unfoundState, fromState, fromParams) ->
