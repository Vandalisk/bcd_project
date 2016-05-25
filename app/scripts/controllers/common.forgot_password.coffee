'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.ForgotPassword', ($rootScope, $scope, Auth, pageCaption) ->
    $rootScope.pageCaption = pageCaption
    $scope.sendResetPasswordLink = mutexAction $scope, ->
      Auth.sendResetPasswordLink
        email: $scope.email
      , (data) ->
        $scope.error = ''
        $scope.message = true
      , (error) ->
        $scope.error = error
