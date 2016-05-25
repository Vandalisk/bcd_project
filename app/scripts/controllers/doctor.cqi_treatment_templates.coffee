'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.CqiTreatmentTemplatesList', ($rootScope, $scope, $state, $filter, user, ActivePatient, TreatmentTemplates, TreatmentDecorator, TreatmentMedicationSchedule, treatmentTemplates, sidebar, sidebarActiveItem, pageCaption, $stateParams) ->
    $scope.user = user
    $scope.treatmentTemplates = treatmentTemplates
    $scope.sidebar = sidebar
    $scope.action = 'new'
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption
    $scope.selectedTreatmentType = ''
    $scope.medicationAction = 'Take'
    $scope.options ||= {}

    $scope.inputTreatmentTypes = [
      { name: 'all treatments', key: '' },
      { name: 'Tablets', key: 'medication_tablets' },
      { name: 'Injection', key: 'medication_injection' },
      { name: 'Lifestyle', key: 'lifestyle' },
      { name: 'Exercise', key: 'exercise' },
      { name: 'Diet', key: 'diet' }
    ]

    $scope.insuranceTypes =
      'yes': 'Covered by BC Pharmacare, once deductible threshold reached'
      'yes_with_authority': 'Covered by BC Pharmacare (if eligible) with completion of Special Authority'
      'partial': 'Partial BC Pharmacare coverage'
      'no': 'Not covered by BC Pharmacare'

    $scope.treatmentTypes = ['medication_tablets', 'medication_injection', 'exercise', 'lifestyle', 'diet']

    $scope.collapseItem = (item) ->
      item.isCollapsed = !item.isCollapsed

    do setDefaults = ->
      angular.extend $scope.options,
        showForm: false
        step: 'name'
        name: false
        type: false
        schedule: false
        description: false

    do defaultsOnEdit = ->
      angular.extend $scope.options,
        showForm: true
        name: true
        type: true
        schedule: true
        description: true

    $scope.filterSelected = (impact) ->
      $scope.filters.impact = impact
      $scope.selectedFilter = impact

    $scope.selectType = (type) ->
      $scope.filters.treatment_type = type
      $scope.selected = type

    $scope.create = ->
      $scope.item = { name: '', data: {}, open_ended: true }
      angular.extend $scope.options, TreatmentDecorator.options($scope.item)
      $rootScope.header = 'doctor.treatment_create'
      $scope.sidebar = 'doctor.treatment_base'
      $scope.options.showForm = true

    $scope.back = ->
      $scope.sidebar = 'doctor.patients.item'
      $rootScope.header = 'base'
      setDefaults()

    $scope.edit = (item) ->
      $('.wrap > .main').scrollTo(0)
      defaultsOnEdit()
      $rootScope.header = 'doctor.treatment_edit'
      $scope.sidebar = 'doctor.treatment_base'
      $scope.action = 'edit'
      $scope.itemIndex = _.indexOf($scope.treatmentTemplates, item)
      $scope.item = angular.copy(item)
      angular.extend $scope.options, TreatmentDecorator.options($scope.item)

    $scope.remove = (item) ->
      TreatmentTemplates.destroy item.id
      .success (data) ->
        $scope.treatmentTemplates.splice((_.indexOf($scope.treatmentTemplates, item)), 1)

    $scope.toggleTreatmentTemplateForm = ->
      $scope.options.showForm = !$scope.options.showForm

    $scope.setTypeHeader = (treatmentType) ->
      $filter('capitalize') (if /medication/i.exec(treatmentType) then 'medication' else treatmentType)

    $scope.list = ->
      TreatmentTemplates.list
        per_page: 1000
      .then (res) ->
        $scope.treatmentTemplates = res.data.collection

angular.module 'bcd'
  .controller 'ctrl.doctor.CqiTreatmentTemplateManage', ($rootScope, $scope, TreatmentTemplates, TreatmentDecorator, TreatmentMedicationSchedule, Notification) ->
    $scope.options ||= {}
    $scope.fn ||= {}
    $scope.treatmentType = 'medicationTabs'
    $scope.errors ||= {}
    $scope.impactColor =
      'high_a1c': 'pink'
      'cholesterol/apob': 'light-blue'
      'high_blood_pressure': 'salad-green'
      'other': 'liliac'

    do setDefaults = ->
      angular.extend $scope.errors,
        name: {}
        type: {}
        schedule: {}
        description: {}
      angular.extend $scope.options,
        showForm: false
        step: 'name'
        name: false
        type: false
        schedule: false
        description: false

    $scope.checkByName = (name) ->
      TreatmentTemplates.checkByName
        name: name

    $scope.chooseImpactColor = (impact) ->
      $scope.impactColor[impact]

    $scope.fn.currentStep = (step) ->
      $scope.options.step == step

    $scope.fn.selectTreatmentType = (type) ->
      $scope.treatmentType = type
      $scope.item.data = {}
      $scope.errors.type = {}

      angular.element('.strength-error-message').remove()
      $scope.item.treatment_type = type

      angular.extend $scope.options, TreatmentDecorator.options($scope.item)

    $scope.fn.showBackButton = ->
      $scope.options.step isnt 'name'

    $scope.fn.isActiveTreatmentType = (type) ->
      $scope.item && $scope.item.treatment_type == type

    $scope.fn.formValid = ->
      switch $scope.options.step
        when "name"
          $scope.errors.name.input = if !$scope.item.name.length then 'Name is too short' else null
          $scope.errors.name.radio = if $scope.item.impact then null else 'Choose, what problem solves this treatment'

          if !$scope.errors.name.input && !$scope.errors.name.radio
            $scope.checkByName($scope.item.name)
        when "type"
          if $scope.item.treatment_type == 'medication_tablets' || $scope.item.treatment_type == 'medication_injection'
            $scope.errors.type.dosage = if $scope.fn.dosageSelected() then null else true

            if $scope.fn.scheduleSelected()
              $scope.errors.type.schedule = null
            else
              $scope.errors.type.schedule = 'Only numbers: 1 - 999'

            if $scope.fn.scheduleSelected() && $scope.fn.dosageSelected()
              return $scope.options.type = true
            else
              return $scope.options.type = false
          if $scope.item.treatment_type == 'exercise'
            $scope.errors.type.count = if $scope.item.data.count && $scope.item.data.count.length > 0 then null else true
            $scope.errors.type.condition = if $scope.item.data.condition && $scope.item.data.condition.length > 0 then null else true

            if $scope.item.data.count && $scope.item.data.condition && $scope.item.data.count.length > 0 &&  $scope.item.data.condition.length > 0
              $scope.errors.type.text = null
              return $scope.options.type = true
            else
              $scope.errors.type.text = 'Set condition for exercise'
              return $scope.options.type = false
          return $scope.options.type = true
        when "schedule"
          if $scope.item.power && $scope.item.power > 0 && ($scope.item.open_ended || $scope.item.period)
            $scope.errors.schedule.input = null
            return $scope.options.schedule = true
          else
            $scope.errors.schedule.input = 'Please select power'
            return $scope.options.schedule = false
        when "description"
          $scope.errors.description.radio = if $scope.item.insurance then null else "This information may influence on patient's choice of treatments"

          if $scope.item.insurance
            return $scope.options.description = true
          else
            return $scope.options.description = false

    $scope.fn.goPreviousStep = ->
      return if $scope.fn.currentStep('name')
      $scope.errors[$scope.options.step] = {}
      $scope.fn.formValid()
      stepIndex = _.indexOf($scope.options.masterSteps, $scope.options.step)
      $scope.options.step = $scope.options.masterSteps[stepIndex - 1]

    $scope.fn.goNextStep = ->
      q = $scope.fn.formValid()
      return if !q || $scope.fn.currentStep('description')
      if $scope.options.step == 'name'
        unless q instanceof Boolean
          if $scope.action == 'new'
            q.then (data) ->
              if data.data.item
                $scope.errors.name.input = 'This name is already used for another treatment'
              else
                $scope.fn.selectTreatmentType('medication_tablets') if !$scope.item.treatment_type
                $scope.options.name = true
                stepIndex = _.indexOf($scope.options.masterSteps, $scope.options.step)
                $scope.options.step = $scope.options.masterSteps[stepIndex + 1]
          else
            $scope.fn.selectTreatmentType('medication_tablets') if !$scope.item.treatment_type
            $scope.options.name = true
            stepIndex = _.indexOf($scope.options.masterSteps, $scope.options.step)
            $scope.options.step = $scope.options.masterSteps[stepIndex + 1]
        $scope.chooseImpactColor()
      else
        $scope.fn.selectTreatmentType('medication_tablets') if !$scope.item.treatment_type
        stepIndex = _.indexOf($scope.options.masterSteps, $scope.options.step)
        $scope.options.step = $scope.options.masterSteps[stepIndex + 1]

    $scope.fn.scheduleSelected = ->
      $scope.item.data.schedule and _.filter($scope.item.data.schedule, (v,k) -> v > 0).length > 0

    $scope.fn.dosageSelected = ->
      $scope.item.data.dosage and $scope.item.data.dosage.length > 0

    $scope.$watch ->
      if $scope.item
        if ($scope.item.treatment_type == 'medication_tablets' || $scope.item.treatment_type == 'medication_injection') && $scope.options.step is 'type'
          $scope.item.data.unit = $scope.options.units[0].key unless $scope.item.data.unit
          $scope.item.data.when = $scope.options.scheduleOptions[0] unless $scope.item.data.when
          $scope.item.data.schedule = TreatmentMedicationSchedule.prepareValues($scope.item.data.schedule)
          $scope.item.data.dosage = null unless $scope.item.data.dosage > 0
          selectedUnit = _.findWhere($scope.options.units, key: $scope.item.data.unit)
          $scope.options.selectedUnit =
            unit: selectedUnit.unit
            action: selectedUnit.action
            thing: selectedUnit.thing
        if $scope.options.step is 'schedule'
          $scope.item.frequency = 'daily' if !$scope.item.frequency
        $scope.item.power = null unless $scope.item.power > 0 && $scope.item.power < 10
        $scope.options.full_name = TreatmentDecorator.fullName($scope.item, false)
        $scope.options.power_points = TreatmentDecorator.calculatedPoints($scope.item)
        $scope.options.month_points = TreatmentDecorator.calculatedPoints($scope.item, true)

    $scope.fn.cancel = ->
      setDefaults()

    $scope.fn.submit = mutexAction $scope, ->
      if $scope.item.id
        TreatmentTemplates.update($scope.item.id, $scope.item)
        .success (data) ->
          Notification.success("#{$scope.item.name} saved")
          $rootScope.header = 'base'
          $scope.$parent.$parent.sidebar = 'doctor.patients.item'
          $scope.treatmentTemplates[$scope.itemIndex] = data.item
          $scope.fn.cancel()
        .error (data) ->
          $scope.errors = data.errors
      else
        TreatmentTemplates.create($scope.item)
        .success (data) ->
          Notification.success("#{$scope.item.name} saved")
          $rootScope.header = 'base'
          $scope.$parent.$parent.sidebar = 'doctor.patients.item'
          $scope.treatmentTemplates.unshift data.item
          $scope.fn.cancel()
        .error (data) ->
          $scope.errors = data.errors

    $scope.fn.showNextButton = ->
      $scope.options.step isnt 'description'
