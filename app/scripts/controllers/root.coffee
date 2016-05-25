'use strict'

angular.module 'bcd'
  .controller 'rootCtrl', ($rootScope, $scope, $state, $stateParams, $window, Auth, AuthSession, ActivePatient, Users, $dialog, $timeout, authService, DialogMessages) ->
    $rootScope.currentUser = AuthSession.user()
    $rootScope.showSearch = false
    $rootScope.header = 'base'

    $rootScope.activePatient = {}
    activePatientId = ActivePatient.get()
    if activePatientId
      Users.item(activePatientId).then (res) ->
        $rootScope.activePatient = res.data.item

    $rootScope.isActivePatient = (user) ->
      user ||= {}
      user.id && (ActivePatient.get() is user.id)

    $scope.clickSidebarEl = (menu, key) ->
      item = _.findWhere menu, key: key if menu
      $state.go item.state.name, item.state.params if item and item.state

    $scope.openCqiTasksExportDialog = ->
      $dialog
        template: 'app/templates/doctor/cqi_export_to_csv.html'
        scope: $scope

    $rootScope.loginForm = {}
    $scope.login = mutexAction $scope, ->
      $rootScope.loginForm.error = ''
      Auth.login
        email: $rootScope.loginForm.email
        password: $rootScope.loginForm.password
      , (user) ->

        if $rootScope.nextState
          # log "login success, redirect to: ", $rootScope.nextState
          # $state.go $rootScope.nextState.state.name, $rootScope.nextState.params, reload: true
          $scope.goNextState()
          $rootScope.nextState = null
        else
          # log "login success, callback to retry buffered requests"
          authService.loginConfirmed()

      , (error) ->
        $rootScope.loginForm.error = error

    $scope.logout = ->
      Auth.logout (user) ->
        # log "logged out, redirect to: ", $state.current
        # $state.go $state.current.name, $stateParams, reload: true
        $state.go AuthSession.homeState(), {}, reload: true

    $rootScope.$on 'event:auth-loginRequired', -> $rootScope.showLogin = true
    $rootScope.$on 'event:auth-loginConfirmed', -> $rootScope.showLogin = false
    $rootScope.$on 'event:auth-loginCancelled', -> $rootScope.showLogin = false
    # $rootScope.$on 'event:auth-loggedOut', -> $rootScope.showLogin = false

    $rootScope.mappedStates = {
      'staff': {
        'doctor.accounts.patients': undefined
        'doctor.accounts.staff': 'doctor.accounts.patients'
        'doctor.cqi_treatment_templates.list': undefined
        'dialogs.list': undefined
        'dialogs.item': 'dialogs.list'
        'doctor.patients.item.dashboard': undefined
        'doctor.patients.item.blood_glucose': 'doctor.patients.item.dashboard'
        'doctor.patients.item.lab_results': 'doctor.patients.item.dashboard'
        'doctor.patients.item.cqi_treatments.list': 'doctor.patients.item.dashboard'
        'doctor.patients.item.cqi_health_program': 'doctor.patients.item.dashboard'
        'doctor.patients.item.cqi_tasks.list': 'doctor.patients.item.dashboard'
      },
      'patient': {
        'dialogs.item': 'dialogs.list'
        'patient.cqi_health_program.list': 'patient.cqi_treatments'
      }
    }

    $scope.goPreviousState = ->
      if $rootScope.previousState and $rootScope.previousState.state and $rootScope.previousState.state.name
        $state.go $rootScope.previousState.state.name, $rootScope.previousState.params, reload: true
      else
        $state.go 'home', {}, reload: true
    $scope.goNextState = ->
      if $rootScope.nextState and $rootScope.nextState.state and $rootScope.nextState.state.name
        $state.go $rootScope.nextState.state.name, $rootScope.nextState.params, reload: true
      else
        $state.go 'home', {}, reload: true
    $scope.goUserDashboard = (user) ->
      if user.role is 'admin' or user.role is 'doctor'
        $state.go 'doctor.doctors.item.dashboard', {userId: user.id}, reload: true
      else if user.role is 'patient'
        $state.go 'doctor.patients.item.dashboard', {userId: user.id}, reload: true

    $rootScope.allowHistoryBack = ->
      $rootScope.getParentState()

    $rootScope.getParentState = ->
      accessGroup = if _.include(['case_manager', 'admin', 'doctor'], $rootScope.currentUser.role) then 'staff' else 'patient'
      $rootScope.mappedStates[accessGroup][$state.current.name]

    $rootScope.goHistoryBack = ->
      parentState = $rootScope.getParentState()
      $state.go(parentState) if parentState

    DialogMessages.subscribeUser(AuthSession.user()) if AuthSession.isLoggedIn()

    $rootScope.$on 'AuthSession:currentUserChanged:login', (event, user) -> DialogMessages.subscribeUser(user)
    $rootScope.$on 'AuthSession:currentUserChanged:logout', (event, user, oldUser) -> DialogMessages.unsubscribeUser(oldUser)
  #    NotificationService.apply($state, AuthSession, $rootScope)
  # $rootScope.$on 'dialogMessages.messageReceived', (event, data) ->
