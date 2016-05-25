'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.CqiTreatmentsList', ($rootScope, AuthSession, $scope, $state, $filter, $timeout, Treatments, Notification, Notifications, TreatmentDecorator, user, treatments, sidebar, sidebarActiveItem, pageCaption) ->
    $scope.user = user
    $scope.treatments = treatments
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    $scope.hintsCollapsed = {
      suggested: true,
      requested: true,
      dpd: true
    }
    $scope.impactColor =
      'high_a1c': 'pink'
      'cholesterol/apob': 'light-blue'
      'high_blood_pressure': 'salad-green'
      'other': 'liliac'

    subscriber = if AuthSession.user().role == 'patient'
      AuthSession.user()
    else
      user
    Notifications.subscribeUser(subscriber, (data) ->
      if AuthSession.user().id != data.sender.id
        if data.resource_type == 'treatment'
          if $scope.$root.currentState.state.controller == 'ctrl.common.CqiTreatmentsList'
            count = data.data.length
            treatment = ''
            list_of_names = ''
            existing = ''
            categories = {
              declined: 'moved %treatmentname% to history',
              active: 'moved %treatmentname% to current',
              new: 'suggested new %treatmentname%',
              suggested: 'suggested %treatmentname%',
              requested: 'requested %treatmentname%',
              new_requested: 'requested new %treatmentname%'
            }
            _.each data.data, (treatment_data) ->
              treatment = TreatmentDecorator.format(JSON.parse(treatment_data).item)
              if count > 1
                list_of_names += "<li>- #{treatment.name}</li>"
              existing = _.find($scope.treatments, {id: treatment.id})
              if existing
                $scope.treatments[_.indexOf($scope.treatments, existing)] = treatment
              else
                $scope.treatments.push(treatment);
            $scope.prepareTreatments()
            if count > 1
              Notification.info
                title: "#{data.sender.name}<br/> #{data.event} #{count} treatments:",
                message: "<ul style='list-style-type: none;'>#{list_of_names}</ul>"
            else
              if existing && data.event == 'requested'
                message_str = categories["new_#{data.event}"]
              else
                message_str = categories[data.event]
              message = message_str.replace('%treatmentname%', treatment.name)
              Notification.info("#{data.sender.name}<br/> #{message}")
    ) if AuthSession.isLoggedIn()

    #    TODO implement DPD
    $scope.DPDTreatments = [JSON.parse('{"id":501,"isCollapsed":"true","sender_id":58,"receiver_id":58,"treatment_template_id":17,"treatment_type":"medication_tablets","name":"Empagliflozin","data":{"unit":"mg tabs","dosage":"25","when":"with","schedule":{"breakfast":1}},"frequency":"daily","period":3,"impact":"high_a1c","power":"30","date_start":null,"date_end":null,"description":"Qui eveniet excepturi ab velit rerum. Est expedita est voluptatum eos voluptatibus vero magnam a. Ratione culpa et eveniet cupiditate sit odit est laboriosam. Eius eum odio ut vel explicabo temporibus numquam facere. Ut aperiam ut qui quasi eligendi.","status":"requested","completion_percent":"0.0","full_name":"25 mg, take 1 tabs with breakfast daily for 3 days","suggest_or_request":null,"doctor_full_name":"Stephon Schoen","patient_full_name":"Stephon Schoen","treatment_template_full_name":"25 mg, take 1 tabs with breakfast daily, for 3 days","accepted_by_full_name":null,"declined_by_full_name":null,"compliance_rate":0,"doctor_comment":null,"patient_comment":null,"sender_gravatar_url":"http://www.gravatar.com/avatar/a63a1c5a75a0e643060a8784ecaaf875?d=mm","receiver_gravatar_url":"http://www.gravatar.com/avatar/a63a1c5a75a0e643060a8784ecaaf875?d=mm","scores":0,"created_at":"2015-12-24T10:42:37+02:00","updated_at":"2015-12-24T10:42:37+02:00","declined_at":null,"$$hashKey":"object:148","frequencyOptions":[{"key":"daily","name":"daily","power_coefficient":1,"month_coefficient":30,"$$hashKey":"object:229"},{"key":"every_other_day","name":"every other day","power_coefficient":2,"month_coefficient":15,"$$hashKey":"object:230"},{"key":"2_days_per_week","name":"2 days per week","power_coefficient":4,"month_coefficient":9,"$$hashKey":"object:231"},{"key":"3_days_per_week","name":"3 days per week","power_coefficient":2,"month_coefficient":13,"$$hashKey":"object:232"},{"key":"4_days_per_week","name":"4 days per week","power_coefficient":2,"month_coefficient":17,"$$hashKey":"object:233"},{"key":"5_days_per_week","name":"5 days per week","power_coefficient":1,"month_coefficient":22,"$$hashKey":"object:234"},{"key":"6_days_per_week","name":"6 days per week","power_coefficient":1,"month_coefficient":25,"$$hashKey":"object:235"},{"key":"weekly","name":"weekly","power_coefficient":8,"month_coefficient":4,"$$hashKey":"object:236"},{"key":"twice_monthly","name":"every two weeks","power_coefficient":15,"month_coefficient":2,"$$hashKey":"object:237"},{"key":"monthly","name":"monthly","power_coefficient":30,"month_coefficient":1,"$$hashKey":"object:238"}],"defaultPeriod":3,"masterSteps":["name","type","schedule","description"],"captionNextStep":"Proceed to dosage form","scheduleOptions":["before","with","after"],"units":[{"key":"mg tabs","name":"mg tabs","unit":"mg","action":"take","thing":"tabs"},{"key":"mg caps","name":"mg caps","unit":"mg","action":"take","thing":"caps"},{"key":"u/ml injections","name":"u/ml injections","unit":"u/ml","action":"inject","thing":"units"},{"key":"mg/ml injections","name":"mg/ml injections","unit":"mg/ml","action":"inject","thing":"mg"}]}')]

    do $scope.prepareTreatments = ->
      items = $filter('filter')($scope.treatments, {status: 'requested'})
      items = $filter('orderBy')(items, 'created_at')
      $scope.requestedTreatments = items

      items = $filter('filter')($scope.treatments, {status: 'new'})
      items = $filter('orderBy')(items, 'created_at')
      $scope.newTreatments = items

      items = $filter('filter')($scope.treatments, {status: 'active'})
      items = $filter('orderBy')(items, 'date_start')
      $scope.activeTreatments = items

      items = $filter('filter')($scope.treatments, {status: 'completed'})
      items = $filter('orderBy')(items, 'updated_at')
      $scope.completedTreatments = items

      items = $filter('inArray')($scope.treatments, ['declined', 'stopped'], 'status')
      items = $filter('orderBy')(items, '-updated_at')
      $scope.inactiveTreatments = items

    $scope.list = ->
      Treatments.list
        receiver_id: user.id
        per_page: 1000
      .then (res) ->
        $scope.treatments = res.data.collection
        $scope.prepareTreatments()

    $scope.collapseItem = (item) ->
      $timeout ( ->
        $scope.$broadcast('elastic:adjust')
      ), 100
      item.model.isCollapsed = !item.model.isCollapsed

    $scope.toggleHint = (type) ->
      $scope.hintsCollapsed[type] = !$scope.hintsCollapsed[type]

    $scope.determineColor = (impact) ->
      $scope.impactColor[impact]

    $scope.openRequestedHint = ->
      $scope.hintsCollapsed.requested = !$scope.hintsCollapsed.requested

    $scope.openSuggestedHint = ->
      $scope.hintsCollapsed.suggested = !$scope.hintsCollapsed.suggested
