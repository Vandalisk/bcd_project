'use strict'

angular.module 'bcd'
.controller 'ctrl.common.bloodGlucoseModal', ($rootScope, $scope, scope, $uibModalInstance, BloodGlucoses) ->
  $scope.currentDate = moment(scope.obj.key).format('YYYY MMMM DD')
  if scope.obj.value == '+'
    $scope.newVal = ''
    $scope.submitBtnText = 'Add'
  else
    $scope.newVal = scope.obj.value
    $scope.submitBtnText = 'Edit'

  $scope.submit = ->
    if ($scope.newVal > 0)
      if (scope.obj.id)
        BloodGlucoses.update(
          scope.obj.id,
          value: $scope.newVal
        ).success (data) ->
          scope.obj.value = $scope.newVal
          $scope.cancel()
      else
        BloodGlucoses.create(
          value: $scope.newVal
          patient_id: scope.patientId,
          when: scope.schedule,
          date: scope.obj.key
        ).success (data) ->
          scope.obj.value = $scope.newVal
          scope.obj.id = data.id
          $scope.cancel()

  $scope.cancel = ->
    scope.obj.visible = false
    $uibModalInstance.dismiss('cancel')

  $scope.$watch 'newVal', (newValue, oldValue) ->
    $scope.newVal = oldValue if newValue > 35 || newValue < 1
