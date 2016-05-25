'use strict'

angular.module 'bcd'
.controller 'ctrl.doctor.CqiHealthProgram', ($rootScope, $scope, $state, $filter, $compile, $q, $timeout, Treatments, TreatmentDecorator, treatmentTemplates, header, sidebar, sidebarActiveItem, pageCaption, user, Notification) ->
  $scope.items = treatmentTemplates
  $scope.sidebar = sidebar
  $scope.user = user
  $scope.stage = 1
  $scope.sidebarActiveItem = sidebarActiveItem
  $rootScope.pageCaption = pageCaption
  $scope.form = false
  $rootScope.header = header

  headerText = 'Choose one or several treatments and suggest to patient. Power determines importance of each treatment, max is 10. Patient will receivemore points for more important treatments.'
  $scope.headerText = headerText
  $scope.activeItem = `undefined`
  $scope.selectedItemIds = []
  $scope.data = {}
  $scope.options = {}
  $scope.options.showThanks = false
  $scope.selectedItems = []

  do $scope.prepareItems = ->
    items = $filter('filter')($scope.items, {treatment_type: 'medication_tablets'})
    items = $filter('orderBy')(items, 'created_at')
    $scope.medicationInjectionItems = items

    items = $filter('filter')($scope.items, {treatment_type: 'medication_injection'})
    items = $filter('orderBy')(items, 'created_at')
    $scope.medicationTabletsItems = items

    items = $filter('filter')($scope.items, {treatment_type: 'lifestyle'})
    items = $filter('orderBy')(items, 'created_at')
    $scope.lifestyleItems = items

    items = $filter('filter')($scope.items, {treatment_type: 'exercise'})
    items = $filter('orderBy')(items, 'created_at')
    $scope.exerciseItems = items

  $scope.collapseItem = (item) ->
    item.isCollapsed = !item.isCollapsed;

  $scope.totalScore = (item) ->
    _.reduce($scope.selectedItems, (i, item) ->
      return i + item.calculatedPoints
    , 0)

  $scope.states = ->
    base_state = 'patient.cqi_health_program'
    list: "#{base_state}.list"
    item: "#{base_state}.item"
    selected: "#{base_state}.selected"

  $scope.toggleActiveItem = (item) ->
    if parseInt($state.params.treatmentTemplateId) is item.id
      $state.go $scope.states().list
    else
      $state.go $scope.states().item, treatmentTemplateId: item.id
    $scope.options.showThanks = false

  $scope.$watch 'currentState.params', ->
    $scope.activeItem = _.findWhere $scope.items, id: parseInt($state.params.treatmentTemplateId)

  $scope.toggleSelect = (item) ->
    if $scope.isSelected item
      $scope.selectedItemIds = _.without $scope.selectedItemIds, item.id
    else
      $scope.selectedItemIds.push item.id

    $scope.selectedItems = _.filter $scope.items, (item) ->
      _.indexOf($scope.selectedItemIds, item.id) >= 0

    $scope.options.showThanks = false
    $state.go $scope.states().list if $rootScope.currentState.state.name is $scope.states().selected

  $scope.isSelected = (item) ->
    item and _.indexOf($scope.selectedItemIds, item.id) >= 0

  $scope.isActive = (item) ->
    $scope.activeItem and $scope.activeItem.id is item.id

  $scope.back = ->
    $scope.stage = 1
    $scope.headerText = headerText

  $scope.backToList = ->
    $rootScope.header = 'base'
    $state.go 'doctor.patients.item.cqi_treatments.list'

  $scope.toForm = ->
    $scope.stage = 2
    $scope.headerText = 'Set dosages to each treatment, add individual recomendations, if needed.'
    $scope.selectedItems.forEach (item) ->
      angular.extend(item, TreatmentDecorator.options(item))
      item.old_data = item.data
      item.receiver_id = user.id
      item.full_name = (html) ->
        fullName = TreatmentDecorator.fullName(item, false, html)
        return fullName.substring(fullName.indexOf(":") + 1)

    $timeout ( ->
      $scope.$broadcast('elastic:adjust')
    ), 500

  $scope.determineColor = (impact) ->
    switch impact
      when 'high_a1c'
        'pink'
      when 'cholesterol/apob'
        'light-blue'
      when 'high_blood_pressure'
        'salad-green'
      when 'other'
        'liliac'

  $scope.toList = ->
    $scope.selectedItems.forEach (item) ->
      item.isCollapsed = true
    $scope.form = false

  $scope.submit = mutexAction $scope, ->
    # TODO: change template output for notification
    name = $scope.selectedItems[0].name
    list_of_names = ""
    count_of_selected_items = $scope.selectedItems.length
    $scope.selectedItems.map (item) ->
      list_of_names += "<li>- #{item.name}</li>"

    Treatments.submit_treatments
      treatment_template_ids: $scope.selectedItemIds
      items: $scope.selectedItems,
      receiver_id: $scope.currentUser.id
    .success (data) ->
      $scope.selectedItemIds = []
      $scope.selectedItems = []
      $rootScope.header = 'base'
      $scope.options.showThanks = true
      $state.go 'doctor.patients.item.cqi_treatments.list', userId: user.id

      if count_of_selected_items is 1
        Notification.success("#{name} was suggested")
      else
        Notification.success
          title: "Suggested #{count_of_selected_items} treatments",
          message: "<ul style='list-style-type: none;'>#{list_of_names}</ul>"
    .error (data) ->
      $scope.errors = data.errors


  $scope.close = ->
    $scope.options.showThanks = false
    $state.go $scope.states().list if $rootScope.currentState.state.name isnt $scope.states().list

  $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    $scope.options.showThanks = false
