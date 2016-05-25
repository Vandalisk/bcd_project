'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.CqiTreatmentsNew', ($scope, $state, $stateParams, Treatments, TreatmentDecorator) ->
    do setDefaults = ->
      $scope.item = {}
      $scope.options =
        showForm: false #true
        step: 'select'
        search: ''
        caption:
          submit: 'Send treatment to patient'

    $scope.options.showForm = $stateParams['new'] is '1'
    $scope.showPreview = ->
      $scope.options.step isnt 'select'

    $scope.$on 'typeahead:selected', (event, tpl) ->
      $scope.options.step = 'edit'
      $scope.item =
        receiver_id: $stateParams.userId
        treatment_template_id: tpl.id
        treatment_type: tpl.treatment_type
        name: tpl.name
        frequency: tpl.frequency
        period: tpl.period
        description: tpl.description
        data: tpl.data
      angular.extend $scope.options, TreatmentDecorator.options($scope.item)

    $scope.showBackButton = -> $scope.options.step is 'edit'

    $scope.goPreviousStep = ->
      setDefaults()
      $scope.options.showForm = true

    $scope.cancel = -> setDefaults()

    $scope.submit = mutexAction $scope, ->
      $scope.errors = {}
      Treatments.create($scope.item)
      .success (data) ->
        if $scope.treatments
          $scope.treatments.unshift data.item
          $scope.prepareTreatments()
        $scope.cancel()
      .error (data) ->
        $scope.errors = data.errors

    $scope.$watch ->
      $scope.options.full_name_small_html = TreatmentDecorator.fullName($scope.item, true, true) if $scope.item


angular.module 'bcd'
  .controller 'ctrl.doctor.CqiTreatmentsEdit', ($rootScope, $scope, $state, $stateParams, Treatments, TreatmentDecorator, user, treatment, sidebar, sidebarActiveItem, pageCaption) ->
    $scope.user = user
    $scope.item = treatment
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    $scope.options =
      step: 'edit'
      search: ''
      caption:
        submit: 'Update'
    angular.extend $scope.options, TreatmentDecorator.options($scope.item)

    if treatment.status is 'requested'
      $rootScope.pageCaption = 'Prescribe treatment'
      $scope.options.caption.submit = 'Prescribe treatment'

    $scope.showPreview = -> true

    $scope.showBackButton = -> false

    $scope.goPreviousStep = -> {}

    $scope.cancel = ->
      $state.go 'doctor.patients.item.cqi_treatments.list', userId: $stateParams.userId

    $scope.submit = mutexAction $scope, ->
      $scope.errors = {}
      action = if $scope.item.status is 'requested' then 'prescribe_requested_treatment' else 'update'
      Treatments[action]($stateParams.treatmentId, $scope.item)
      .success (data) ->
        $state.go 'doctor.patients.item.cqi_treatments.list', userId: $stateParams.userId
      .error (data) ->
        $scope.errors = data.errors

    $scope.$watch ->
      $scope.options.full_name_small_html = TreatmentDecorator.full_name($scope.item, true, true) if $scope.item
