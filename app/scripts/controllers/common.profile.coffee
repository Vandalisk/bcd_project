'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.Profile', ($rootScope, $scope, $state, Profile, AuthSession, user, pageCaption, DateSelectOptions) ->
    $scope.user = user
    $rootScope.pageCaption = pageCaption
    $scope.allowChangeRole = false
    $scope.allowChangePassword = true
    $scope.born = DateSelectOptions($scope.user.birthday)

    $scope.captions =
      submit: 'Update'

    $scope.submit = mutexAction $scope, ->
      $scope.errors = {}
      Profile.profileSubmit $scope.user
      .success (data) ->
        $state.go AuthSession.homeState()
      .error (data) ->
        $scope.errors = data.errors
    $scope.cancel = ->
      $scope.goPreviousState()

    $scope.$watch ->
      $scope.user.birthday = moment($scope.born.date.year + ' ' + $scope.born.date.month + ' ' + $scope.born.date.day).format('YYYY-MM-DD')

