'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.accounts', ($rootScope, $scope, sidebar, sidebarActiveItem, pageCaption, user) ->
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $scope.user = user
    $scope.showOnlyAssigned = true
    $scope.reverse = true
    $scope.showAccountsSearch = false
    $scope.showFiltersModal = false

    $scope.filterQuery = {
      filter_fields: {}
    }

    $scope.order = (predicate) ->
      $scope.reverse = if $scope.predicate is predicate then !$scope.reverse else false
      $scope.predicate = predicate;

    $scope.predicateIsActive = (field) ->
      $scope.predicate == field

    $scope.toggleFiltersModal = ->
      $scope.showFiltersModal = !$scope.showFiltersModal;

    $scope.toggleAccountsSearch = ->
      $scope.showAccountsSearch  = !$scope.showAccountsSearch

    $rootScope.$watch 'pageCaption', ->
      $scope.showFiltersModal = false
