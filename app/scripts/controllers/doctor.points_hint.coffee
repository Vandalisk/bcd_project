'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.pointsHint', ($scope, $uibModalInstance) ->
    $scope.close = ->
      $uibModalInstance.dismiss('cancel');
