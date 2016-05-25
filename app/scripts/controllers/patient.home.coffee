'use strict'

angular.module 'bcd'
  .controller 'ctrl.patient.Home', ($rootScope, $scope, $state, $timeout, newTreatmentsCount, sidebar, sidebarActiveItem, pageCaption) ->

    # if user has suggested treatments - notify (default behavior)
    # if user doesn't have suggested treatments - redirect to "/tasks"
    $scope.newTreatmentsCount = newTreatmentsCount
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption
    $timeout ->
      $state.go('patient.cqi_tasks.list') if newTreatmentsCount is 0

