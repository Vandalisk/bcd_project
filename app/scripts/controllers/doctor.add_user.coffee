'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.AddUser', ($rootScope, $scope, Users, sidebar, sidebarActiveItem, pageCaption, DateSelectOptions) ->
    $scope.user = {}
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    if $scope.currentUser.role == 'case_manager'
      $scope.user.role = 'patient'
    if $scope.currentUser.role == 'doctor'
      $scope.user.role = 'case_manager'
    $scope.allowChangePassword = false
    $scope.born = DateSelectOptions()
    $scope.captions =
      submit: 'Create User Profile'

    $scope.submit = mutexAction $scope, ->
      $scope.errors = {}
      Users.create $scope.user
      .success (data) ->
        $scope.goUserDashboard(data.item)
      .error (data) ->
        $scope.errors = data.errors
    $scope.cancel = ->
      $scope.goPreviousState()

    $scope.$watch ->
      $scope.user.birthday = moment($scope.born.date.year + ' ' + $scope.born.date.month + ' ' + $scope.born.date.day).format('YYYY-MM-DD')

