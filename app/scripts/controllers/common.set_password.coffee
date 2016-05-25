'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.SetPassword', ($rootScope, $scope, $state, $stateParams, Auth, AuthSession, Users, user, token_type, pageCaption) ->
    $scope.user = user
    $scope.phn = ""
    $scope.passwordForm = false
    $rootScope.pageCaption = pageCaption

    updatePassword = mutexAction $scope, ->
      Auth.updatePassword
        token_type: token_type
        token: $stateParams.token
        password: $scope.user.password
      , (user) ->
        $state.go(if token_type is 'invite' then 'profile' else AuthSession.homeState())
      , (error) ->
        $scope.error = error


    confirmPHN = mutexAction $scope, ->
      Users.check_phn(user.id, phn: $scope.phn)
      .success (response) ->
        if response.response
          $scope.passwordForm = true
          $scope.error = null
        else
          $scope.error = response.message
      .error (error) ->
        $scope.error = error.message

    $scope.checkPassword = (user) ->
      if user.password is user.passwordConfirmation
        $scope.user.password = user.password
        updatePassword()
      else
        $scope.error = "Sorry, password and password confirmation don't match. Please try again"

    $scope.checkPHN = (phn) ->
      if phn.match(/^\d+$/)
        $scope.phn = phn
        confirmPHN()
      else
        $scope.error = "PHN requires numbers only"
