'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.changeRequestTreatment', ($scope, $timeout, scope, $uibModalInstance, TreatmentDecorator, Treatments, updateList, Notification) ->
    $scope.userId = scope.user.id
    $scope.treatmentId = scope.activeItem.id
    $scope.treatments = scope.treatments
    $scope.item = angular.copy(scope.activeItem)
    $scope.formDisabled = false
    angular.extend($scope.item, TreatmentDecorator.options($scope.item))

    $scope.cancel = ->
      $uibModalInstance.dismiss('cancel')

    $timeout ( ->
      $scope.$broadcast('elastic:adjust')
    ), 500

    $scope.submit = ->
      if !$scope.formDisabled
        $scope.formDisabled = true
        Treatments.update_current(
          $scope.item.id,
          status: 'requested',
          doctor_comment: $scope.item.doctor_comment,
          patient_comment: $scope.item.patient_comment,
          data: $scope.item.data,
          description: $scope.item.description
        )
        .success (data) ->
          $uibModalInstance.dismiss('cancel')
          setTimeout ->
            $scope.formDisabled = false
          , 200
          $scope.item = TreatmentDecorator.format(data.item)
          $scope.treatments[_.indexOf($scope.treatments, _.find($scope.treatments, {id: $scope.item.id}))] = $scope.item
          updateList()
          if $scope.currentUser.role is 'patient'
            Notification.success("New #{$scope.item.name} was requested")
          else
            Notification.success("New #{$scope.item.name} was suggested")
        .error () ->
          $scope.formDisabled = false
