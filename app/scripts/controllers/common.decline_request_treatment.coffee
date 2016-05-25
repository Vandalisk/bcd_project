'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.declineRequestTreatment', ($scope, scope, $uibModalInstance, TreatmentDecorator, Treatments, updateList, Notification) ->
    $scope.userId = scope.user
    $scope.treatmentId = scope.activeItem
    $scope.item = angular.copy(scope.activeItem)
    $scope.treatments = scope.treatments
    $scope.formDisabled = false
    angular.extend($scope.item, TreatmentDecorator.options($scope.item))

    $scope.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $scope.decline = ->
      if !$scope.formDisabled
        $scope.formDisabled = true
        Treatments.update(
          $scope.item.id,
          status: 'declined',
          doctor_comment: $scope.item.doctor_comment,
          patient_comment: $scope.item.patient_comment,
          data: $scope.item.data
        )
        .success (data) ->
          $uibModalInstance.dismiss('cancel')
          setTimeout ->
            $scope.formDisabled = false
          , 200
          $scope.item = TreatmentDecorator.format(data.item)
          $scope.treatments[_.indexOf($scope.treatments, _.filter($scope.treatments, {id: $scope.item.id})[0])] = $scope.item
          updateList()
          Notification.success("#{$scope.item.name} was moved to history")
