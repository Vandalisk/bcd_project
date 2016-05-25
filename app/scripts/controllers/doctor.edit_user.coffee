'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.EditUser', ($rootScope, $scope, $stateParams, Users, user, sidebar, sidebarActiveItem, pageCaption, DateSelectOptions) ->
    $scope.user = user
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    $scope.allowChangeRole = false
    $scope.allowChangePassword = false
    $scope.born = DateSelectOptions($scope.user.birthday)
    $scope.captions =
      submit: 'Update'

    $scope.submit = mutexAction $scope, ->
      $scope.errors = {}
      Users.update($stateParams.userId, $scope.user)
      .success (data) ->
        $scope.goUserDashboard(data.item)
      .error (data) ->
        $scope.errors = data.errors
    $scope.cancel = ->
      $scope.goUserDashboard($scope.user)

    $scope.$watch ->
      $scope.user.birthday = moment($scope.born.date.year + ' ' + $scope.born.date.month + ' ' + $scope.born.date.day).format('YYYY-MM-DD')
