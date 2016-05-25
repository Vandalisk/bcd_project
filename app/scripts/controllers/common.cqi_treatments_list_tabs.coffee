'use strict'

angular.module 'bcd'
  .controller 'CqiTreatmentsListTabsController', ($scope) ->
    $scope.tab = 1

    $scope.setTab = (newValue) ->
      $scope.tab = newValue

    $scope.isSet = (tabName) ->
      $scope.tab == tabName
