'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.accounts.staff', ($rootScope, $scope, pageCaption, Accounts) ->
    $rootScope.pageCaption = pageCaption
    $scope.$parent.predicate = 'full_name'

    Accounts.staff per_page: 30
    .then (res) ->
      $scope.staff = Accounts.prepareList res
