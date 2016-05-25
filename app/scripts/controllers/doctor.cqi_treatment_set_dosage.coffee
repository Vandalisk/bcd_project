'use strict'

angular.module 'bcd'
.controller 'ctrl.doctor.approveRequestTreatment', ($scope, user, treatment, TreatmentDecorator) ->
  $scope.userId = user
  $scope.treatmentId = treatment
  $scope.item = treatment

.controller 'ctrl.doctor.changeRequestTreatment', ($scope, user, treatment, $uibModalInstance, TreatmentDecorator) ->
  $scope.userId = user
  $scope.treatmentId = treatment
  $scope.item = treatment
  angular.extend($scope.item, TreatmentDecorator.options($scope.item))

  $scope.cancel = ->
    $uibModalInstance.dismiss('cancel')

.controller 'ctrl.doctor.CqiTreatmentSetDosage', ($scope, TreatmentDecorator, Treatments, Notification) ->
  angular.extend($scope.item, TreatmentDecorator.options($scope.item))
  $scope.formDisabled = false
  $scope.suggestDosage = ->
    if !$scope.formDisabled
      $scope.formDisabled = true
      Treatments.prescribe_requested_treatment($scope.item.id, $scope.item)
      .success (data) ->
        Notification.success("#{$scope.item.name} was approved")
        $scope.item = TreatmentDecorator.format(data.item)
        $scope.treatments[_.indexOf($scope.treatments, _.find($scope.treatments, {id: $scope.item.id}))] = $scope.item
        $scope.prepareTreatments()
        $scope.formDisabled = false
      .error (data) ->
        $scope.errors = data.errors
