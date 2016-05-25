'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.approveRequestTreatment', ($scope, user, treatment, TreatmentDecorator) ->
    $scope.userId = user
    $scope.treatmentId = treatment
    $scope.item = treatment

  .controller 'ctrl.doctor.changeRequestTreatment', ($scope, user, treatment, $uibModalInstance, TreatmentDecorator, Treatments, updateList) ->
    $scope.userId = user.id
    $scope.treatmentId = treatment.id
    $scope.item = treatment
    angular.extend($scope.item, TreatmentDecorator.options($scope.item))

    $scope.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $scope.suggest = ->
      Treatments.update_current($scope.item.id, status: 'requested', comment: $scope.item.comment)
        .success (data) ->
          updateList()
          $uibModalInstance.dismiss('cancel')

  .controller 'ctrl.doctor.declineRequestTreatment', ($scope, user, treatment, $uibModalInstance, TreatmentDecorator, Treatments, updateList) ->
    $scope.userId = user
    $scope.treatmentId = treatment
    $scope.item = treatment
    angular.extend($scope.item, TreatmentDecorator.options($scope.item))

    $scope.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $scope.decline = ->
      Treatments.update($scope.item.id, status: 'declined', comment: $scope.item.comment)
        .success (data) ->
          updateList()
          $uibModalInstance.dismiss('cancel')
