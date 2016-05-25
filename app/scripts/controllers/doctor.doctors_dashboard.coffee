'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.DoctorsDashboard', ($rootScope, $scope, user, sidebar, sidebarActiveItem, pageCaption) ->
    $scope.user = user
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption
