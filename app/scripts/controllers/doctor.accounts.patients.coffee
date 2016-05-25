'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.accounts.patients', ($rootScope, $scope, AuthSession, Notifications, Notification, TreatmentDecorator, $filter, pageCaption, Accounts, user) ->
    $rootScope.pageCaption = pageCaption
    $scope.$parent.predicate = 'treatments.length'

    Accounts.patients per_page: 30
    .then (res) ->
      $scope.patients = Accounts.prepareList res
      $scope.filteredPatients = $filter('filter')($scope.patients, {doctor_id: $scope.currentUser.id})

    subscriber = if AuthSession.user().role == 'patient'
      AuthSession.user()
    else
      user
    Notifications.subscribeUser({id: 0}, (data) ->
      if AuthSession.user().id != data.sender.id
        if data.resource_type == 'treatment'
          if $scope.currentState.state.controller == 'ctrl.doctor.accounts.patients'
            treatment = JSON.parse(data.data[0]).item
            patient = _.find($scope.patients, {id: treatment.receiver_id})
            list_of_names = ''
            categories = {
              declined: 'moved %treatmentname% to history',
              requested: 'requested %treatmentname%',
              new_requested: 'requested new %treatmentname%'
            }
            count = data.data.length
            _.each data.data, (treatment_data) ->
              t = TreatmentDecorator.format(JSON.parse(treatment_data).item)
              if count > 1
                list_of_names += "<li>- #{treatment.name}</li>"
              if t.status == 'declined'
                patient.treatments.pop()
              else if t.status == 'requested'
                patient.treatments.push({source: 'BCD', date: moment(t.created_at)})
            patient.last_date = moment.max(_.map(patient.treatments, 'date')).format('DD MMM')
            if _.include(['requested', 'declined'], treatment.status)
              if count > 1
                Notification.info
                  title: "#{data.sender.name}<br/> #{data.event} #{count} treatments:",
                  message: "<ul style='list-style-type: none;'>#{list_of_names}</ul>"
              else
                message = categories[data.event].replace('%treatmentname%', treatment.name)
                Notification.info("#{data.sender.name}<br/> #{message}")
    ) if AuthSession.isLoggedIn()

    #TODO delete me and return directive!!!
    $scope.requestedTreatmentsOnDashboard = (patient) ->
      bcd = _.filter patient.treatments, (x) ->
        x.source == 'BCD'
      dpd = _.filter patient.treatments, (x) ->
        x.source == 'DPD'
      bcd_str = if bcd.length > 0 then bcd.length + ' requested' else ''
      dpd_str = if dpd.length > 0 then dpd.length + ' from DPD' else ''
      connector = if bcd.length > 0 && dpd.length > 0 then ' & ' else ''
      bcd_str + connector + dpd_str

    $scope.$watch 'showOnlyAssigned', ->
      if $scope.showOnlyAssigned
        $scope.filteredPatients = $filter('filter')($scope.patients, {doctor_id: $scope.currentUser.id})
      else
        $scope.filteredPatients = $scope.patients
