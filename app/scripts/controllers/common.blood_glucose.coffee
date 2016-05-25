'use strict'

angular.module 'bcd'
.controller 'ctrl.common.bloodGlucose', ($rootScope, $scope, $localStorage, BloodGlucoses, AuthSession, Notifications, user, sidebar, sidebarActiveItem, pageCaption) ->
  $scope.user = user
  $scope.sidebar = sidebar
  $scope.sidebarActiveItem = sidebarActiveItem
  $rootScope.pageCaption = pageCaption

  $scope.schedules = [
    "before breakfast"
    "after breakfast"
    "before lunch"
    "after lunch"
    "before dinner"
    "after dinner"
    "before bed"
    "early hours"
  ]

  $scope.months = [];
  moment.range(moment().subtract(2, 'year'), moment()).by 'month', (moment) ->
    $scope.months.push(moment.format('MMMM YYYY'))
  $scope.months.reverse()

  $scope.dataSetNotEmpty = ->
    Object.keys($scope.data).length > 0

  $scope.selectedMonth = moment().format('MMMM YYYY');

  $scope.subscriber = if AuthSession.user().role == 'patient'
    AuthSession.user()
  else
    user
  Notifications.subscribeUser($scope.subscriber, (data) ->
    if AuthSession.user().id != data.sender.id
      if data.resource_type == 'blood_glucose'
        if $scope.currentState.state.controller == 'ctrl.common.bloodGlucose'
          $scope.data[data.data.when][data.data.date].value = data.data.value
  ) if AuthSession.isLoggedIn()


  $scope.data = {}
  $scope.fillData = ->
    moment.range(moment('1 ' + $scope.selectedMonth).startOf('month'), moment('1 ' + $scope.selectedMonth).endOf('month')).by 'days', (date) ->
      $scope.dates.push(
        label: date.format('MMM DD')
        value: date.format('YYYY-MM-DD')
      ) if moment() > date

    _.each $scope.schedules, (schedule) ->
      $scope.data[schedule] = {}
      _.each $scope.dates, (date) ->
        $scope.data[schedule][date.value] = {value: '+', visible: false }
      _.each $scope.blood_glucoses, (x) ->
        _.each x.measurements, (measurement) ->
          if measurement.when == schedule
            $scope.data[schedule][x.date] =
              id: measurement.id,
              value: parseFloat(measurement.value).toFixed(2)
              visible: false

  $scope.openPopup = (key, value, i, k, v) ->
    obj = value[$scope.dates[i].value]
    if v.visible
      v.visible = false
    else
      _.each $scope.data, (schedule) ->
        _.each schedule, (date) ->
          date.visible = false
      v.visible = true

  $scope.$watch 'selectedMonth', (newValue, oldValue) ->
    if $scope.selectedMonth
      $scope.dates = [];
      date = '1 ' + $scope.selectedMonth
      $scope.selectedDate = moment(date, 'MMMM YYYY')
      month = $scope.selectedDate.format('MM')
      year = $scope.selectedDate.format('YYYY')
      BloodGlucoses.list(patient_id: $scope.user.id, year: year, month: month).then (res) ->
        $scope.blood_glucoses = res.data;
        $scope.fillData()
