'use strict'

angular.module 'bcd'
  .factory 'Share', ->
    $scope.data ||= {}


  .factory 'AuthSession', ($rootScope, $localStorage, Acl) ->
    anonUser =
      role: Acl.anonRole

    prepare = (userData) ->
      fields = ['id', 'email', 'full_name', 'gravatar_url', 'role', 'token', 'total_score', 'current_score']
      user = {}
      angular.forEach fields, (field) ->
        user[field] = userData[field]
      user

    user: ->
      $localStorage.currentUser or anonUser

    set: (userData) ->
      user = prepare userData
      $localStorage.currentUser = user
      $rootScope.currentUser = user
      $rootScope.$emit 'AuthSession:currentUserChanged:login', user
      user

    remove: ->
      oldUser = @user()
      delete $localStorage.currentUser
      $rootScope.currentUser = anonUser
      $rootScope.$emit 'AuthSession:currentUserChanged:logout', anonUser, oldUser
      anonUser

    authorize: (access, role) ->
      role = @user().role if role is `undefined`
      if access is '*'
        true
      else
        access.indexOf(role) >= 0

    isLoggedIn: ->
      @user().role isnt Acl.anonRole

    homeState: ->
      user = @user()
      if user.role is 'admin' or user.role is 'doctor' or user.role is 'case_manager'
        'doctor.accounts.patients'
      else if user.role is 'patient'
        'patient.home'
      else
        'home'


  .factory 'Auth', ($rootScope, $http, AuthSession, ActivePatient) ->
    login: (data, success, error) ->

      $http
        method: 'post',
        url: "#{appConfig.urlApi}/auth/login",
        ignoreAuthModule: true
        data: data
      .success (data, status, headers, config) ->
        user = AuthSession.set data.item
        success user
      .error (data, status, headers, config) ->
        error data.message

    logout: (success, error) ->
      # $http.post "#{appConfig.urlApi}/auth/logout"
      # .success (data, status, headers, config) ->
      #   user = AuthSession.remove()
      #   success user
      # .error (data, status, headers, config) ->
      #   error data.message

      # TODO: make event
      ActivePatient.remove()
      $rootScope.activePatient = {}

      user = AuthSession.remove()
      success user

    sendResetPasswordLink: (data, success, error) ->
      $http
        method: 'post'
        url: "#{appConfig.urlApi}/auth/send_reset_password_link",
        ignoreAuthModule: true
        data: data
      .success (data, status, headers, config) ->
        success data
      .error (data, status, headers, config) ->
        error data.message

    findByToken: (data) ->
      $http.get "#{appConfig.urlApi}/auth/token/#{data.token_type}/#{data.token}"

    updatePassword: (data, success, error) ->
      $http
        method: 'post'
        url: "#{appConfig.urlApi}/auth/update_password",
        ignoreAuthModule: true
        data: data
      .success (data, status, headers, config) ->
        user = AuthSession.set data.item
        success user
      .error (data, status, headers, config) ->
        error data.message


  .factory 'ActivePatient', ($rootScope, $localStorage, Users) ->
    get: ->
      $localStorage.activePatientId
    set: (userId) ->
      $localStorage.activePatientId = userId
    remove: ->
      delete $localStorage.activePatientId


  .factory 'Faye', ($rootScope, AuthSession) ->
    client = new Faye.Client("#{appConfig.urlApi}/faye")
    client.addExtension
      outgoing: (message, callback) ->
        token = AuthSession.user().token
        if token
          message.ext ||= {}
          message.ext.auth_token = token
        callback(message)

    client: client

    subscribe: (channel, callback) ->
      @client.subscribe channel, (data) ->
        $rootScope.$apply ->
          callback(data)

    unsubscribe: (channel) ->
      @client.unsubscribe channel
      # $rootScope.$apply()

    publish: (channel, data) ->
      @client.publish channel, data
      # $rootScope.$apply()


  .factory 'Accounts', ($http, $state) ->
    patients = (params) ->
      $http.get "#{appConfig.urlApi}/accounts/patients", params: params
    staff = (params) ->
      $http.get "#{appConfig.urlApi}/accounts/staff", params: params
    prepareItem = (item) ->
      _.each item.treatments, (t) ->
        t.date = moment(t.date)
      item.last_date = moment.max(_.map item.treatments, 'date').format('DD MMM')
      item.filter_fields = {
        full_name: item.full_name
        role: item.role
        phn: item.phn
        birthday: item.date_of_birth
      }
    prepareList = (res) ->
      _.each res.data, (item) ->
        prepareItem(item)

    {
    patients: patients,
    staff: staff,
    prepareItem: prepareItem,
    prepareList: prepareList
    }

  .factory 'TreatmentMedicationSchedule', ->
    prepareValues: (rawData) ->
      rawData = {} unless rawData
      schedule = {}
      _.each ['breakfast', 'lunch', 'dinner', 'bedtime'], (k) ->
        schedule[k] = rawData[k] if rawData[k] and rawData[k] > 0 and rawData[k] < 999
      schedule

  .factory 'TreatmentTemplateTotalScoreCalculator', ->
    options =
      daily: {days: '1,day', powerCoefficient: 1}
      every_other_day: {days: '2,day', powerCoefficient: 2}
      '6_days_per_week': {days: [1,2,3,4,5,6], powerCoefficient: 1}
      '5_days_per_week': {days: [1,2,3,4,5], powerCoefficient: 1}
      '4_days_per_week': {days: [0,1,3,5], powerCoefficient: 2}
      '3_days_per_week': {days: [1,3,5], powerCoefficient: 2}
      '2_days_per_week': {days: [2,4], powerCoefficient: 4}
      weekly: {days: '1,week', powerCoefficient: 8}
      twice_monthly: {days: '2,week', powerCoefficient: 15}
      monthly: {days: '1,month', powerCoefficient: 30}

    calculate: (item) ->
      startDate = item.start_date || moment().add(1, 'days')
      if item.end_date
        endDate = item.end_date
      else
        endDate = if item.open_ended then moment().add(6, 'month') else moment().add(item.period, 'days')
      days = options[item.frequency].days
      powerCoefficient = options[item.frequency].powerCoefficient
      daysCount = 0
      if Array.isArray(days)
        moment.range(startDate, endDate).by 'days', (moment) ->
          daysCount++ if _.contains(days, parseInt(moment.format("e")))
      else if typeof(days) == 'string'
        dateCount = days.split(',')[0]
        dateType = days.split(',')[1]
        loop
          daysCount++
          break if startDate >= endDate
          startDate.add(dateCount, dateType)
      (powerCoefficient * item.power) * daysCount

  .factory 'Notifications', ($rootScope, Faye) ->
    subscribeUser = (user, cb) ->
      unsubscribeUser(user)
      Faye.subscribe "/notifications/#{user.id}", (data) ->
        cb(data)

    unsubscribeUser = (user) ->
      Faye.unsubscribe "/notifications/#{user.id}"

    subscribeUser: subscribeUser
    unsubscribeUser: unsubscribeUser

  #  .factory 'NotificationService', ($state, AuthSession, Notifications) ->
  #    apply: ($state, $rootScope) ->
  #      subscriber = if AuthSession.user().role == 'patient'
  #        AuthSession.user()
  #      else
  #        user
  #      console.log('applying notification service', $state.current)
  #      debugger
  #      Notifications.subscribeUser(subscriber, (data) ->
  #        if AuthSession.user().id != data.sender.id
  #          if data.resource_type == 'treatment'
  #            count = data.data.length
  #            treatment = ''
  #            list_of_names = ''
  #            existing = ''
  #            categories = {
  #              declined: 'moved %treatmentname% to history',
  #              active: 'moved %treatmentname% to current',
  #              new: 'suggested new %treatmentname%',
  #              suggested: 'suggested %treatmentname%',
  #              requested: 'requested %treatmentname%',
  #              new_requested: 'requested new %treatmentname%'
  #            }
  #            console.log(data.event)
  #            _.each data.data, (treatment_data) ->
  #              treatment = TreatmentDecorator.format(JSON.parse(treatment_data).item)
  #              if count > 1
  #                list_of_names += "<li>- #{treatment.name}</li>"
  #              existing = _.find($scope.treatments, {id: treatment.id})
  #              if existing
  #                $scope.treatments[_.indexOf($scope.treatments, existing)] = treatment
  #              else
  #                $scope.treatments.push(treatment);
  #            $scope.prepareTreatments()
  #            if count > 1
  #              Notification.info
  #                title: "#{data.sender.name}<br/> #{data.event} #{count} treatments:",
  #                message: "<ul style='list-style-type: none;'>#{list_of_names}</ul>"
  #            else
  #              if existing && data.event == 'requested'
  #                message_str = categories["new_#{data.event}"]
  #              else
  #                message_str = categories[data.event]
  #              debugger
  #              message = message_str.replace('%treatmentname%', treatment.name)
  #              console.log(message_str, message)
  #              Notification.info("#{data.sender.name}<br/> #{message}")
  #      ) if AuthSession.isLoggedIn()

  .factory 'DialogMessages', ($rootScope, $interval, Dialogs, Messages, Faye) ->
    prepareMessages = (scope, items) ->
      start_of_day = moment().startOf('day')
      _.map items, (item) ->
        time = moment(item.created_at)
        if time > start_of_day
          format = 'HH:mm'
        else
          format = 'YYYY-MM-DD'
        item.formatted_date = moment(item.created_at).format(format)
        item.sender_full_name = sender.full_name if !item.sender_full_name and item.sender
        item.sender_gravatar_url = sender.gravatar_url if !item.sender_gravatar_url and item.sender
        item.is_mine = $rootScope.currentUser.id is item.sender_id
        item

    groupMessages = (scope, items) ->
      _.map items, (item, i) ->
        previousItem = items[i-1]
        item.css_class = if previousItem and previousItem.sender_id is item.sender_id then "short" else ""
        item

    setFirstAndLastIds = (scope) ->
      if scope.messages and scope.messages.length > 0
        scope.first_id = _.first(scope.messages).id
        scope.last_id = _.last(scope.messages).id
      else
        scope.first_id = `undefined`
        scope.last_id = `undefined`

    loadInitial = (scope) ->
      Messages.list
        dialog_with: scope.activeItem.id
        per_page: 500
        order: "id desc"
      .then (res) ->
        items = res.data.collection
        items = items.reverse()
        items = prepareMessages scope, items
        scope.messages = groupMessages scope, items
        setFirstAndLastIds scope
        $rootScope.$emit 'dialogMessages.loadInitial'

    loadOld = (scope) ->
      Messages.list
        dialog_with: scope.activeItem.id
        per_page: 500
        order: "id desc"
        id_lt: scope.first_id
      .then (res) ->
        items = res.data.collection
        items = items.reverse()
        items = prepareMessages scope, items
        items = items.concat (scope.messages || [])
        scope.messages = groupMessages scope, items
        setFirstAndLastIds scope
        $rootScope.$emit 'dialogMessages.loadOld'

    subscribeUser = (user) ->
      unsubscribeUser(user)
      Faye.subscribe "/messages/#{user.id}", (data) ->
        # log "MESSAGE:"
        log data
        $rootScope.$emit 'dialogMessages.messageReceived', data
        $rootScope.dialogsUnreadCount = data.dialogs_unread_count if data.new_item and data.new_item.sender_id isnt $rootScope.activeDialogWith
        $rootScope.dialogsUnreadCount = data.dialogs_unread_count if data.updated_item || data.updated_item_ids

      Dialogs.dialogs_unread_count().then (res) ->
        $rootScope.dialogsUnreadCount = res.data.dialogs_unread_count

    unsubscribeUser = (user) ->
      Faye.unsubscribe "/messages/#{user.id}"
      $rootScope.dialogsUnreadCount = 0

    prepareMessages: prepareMessages
    groupMessages: groupMessages
    setFirstAndLastIds: setFirstAndLastIds
    loadInitial: loadInitial
    loadOld: loadOld
    subscribeUser: subscribeUser
    unsubscribeUser: unsubscribeUser

  .factory 'FrequencyOptions', ->
    options = (decorator, item) ->
      opts =
        frequencyOptions: [
          { key: 'daily', name: 'daily', power_coefficient: 1, month_coefficient: 30 }
          { key: 'every_other_day', name: 'every other day', power_coefficient: 2, month_coefficient: 15 }
          { key: '2_days_per_week', name: '2 days per week', power_coefficient: 4, month_coefficient: 9 }
          { key: '3_days_per_week', name: '3 days per week', power_coefficient: 2, month_coefficient: 13 }
          { key: '4_days_per_week', name: '4 days per week', power_coefficient: 2, month_coefficient: 17 }
          { key: '5_days_per_week', name: '5 days per week', power_coefficient: 1, month_coefficient: 22 }
          { key: '6_days_per_week', name: '6 days per week', power_coefficient: 1, month_coefficient: 25 }
          { key: 'weekly', name: 'weekly', power_coefficient: 8, month_coefficient: 4 }
          { key: 'twice_monthly', name: 'every two weeks', power_coefficient: 15, month_coefficient: 2 }
          { key: 'monthly', name: 'monthly', power_coefficient: 30, month_coefficient: 1 }
        ]
        defaultPeriod: 3
      angular.extend {}, opts, decorator.options

    calculatedPoints = (item, month) ->
      option = _.find(options(item).frequencyOptions, {key: item.frequency})
      if option && item.power
        res = option.power_coefficient * item.power
        if month then res * option.month_coefficient else res

    options: options
    calculatedPoints: calculatedPoints

  .factory 'LabResultsShaper', (LabResults) ->

    labResultsDef = -> LabResult.INDICATORS

    columnDefs = (data) ->
      results = data.sort (a, b) ->
        new Date(b.date) - new Date(a.date)
      res = [{
        headerName: 'Test'
        field: 'code'
        headFieldsDate: new Date()
        width: 95
        columnNumber: 0
      }]

      dates = _.chain(results).pluck('date').unique().value()
      _.union(res, _.map dates, (date, i) =>
          dateParts = date.split('-')
          headFieldValue = "#{dateParts[0]}<br>#{moment(date).format('MMM')} #{dateParts[2]}"
          headFieldDate = new Date(dateParts)
          {
          headerName: headFieldValue
          field: date
          headFieldsDate: headFieldDate
          width: 95
          columnNumber: i+1
          }
      )

    rowData = (results, headers, indicators) ->
      labData = []
      _.each Object.keys(indicators), (codeName, i) ->
        labData[i] = {
          code: codeName,
          visible: false
        }
        for j in [1...headers.length]
          labData[i][headers[j].field] = 0

      _.each results, (result) ->
        index = undefined
        object = _.find labData,(_labData, i) ->
          index = i
          result.code == _labData.code
        labData[index][result.date] = result.value.match(/[0-9]|\./g).join('')
        labData[index].maxValue = result["max_value "] if not labData[index].maxValue? and result["max_value "]
        labData[index].minValue = result["min_value"] if not labData[index].minValue? and result["min_value"]
      labData

    lastTestDate = (columnDefs) ->
      _.max(_.map(columnDefs, (item) =>
        item.headFieldsDate
      ))

    isAbnormal = (item, date) ->
      return false if item[date] == '-'
      item.maxValue? && item[date] > item.maxValue || item.minValue? && item[date] < item.minValue

    abnormalTests = (columnDefs, rowData) ->
      lastColumnField = columnDefs[1]
      if lastColumnField && lastColumnField.field != 'code'
        index = lastColumnField.field
        abnormals = _.filter(rowData, (item) ->
          isAbnormal(item, index)
        )
        _.reduce(abnormals, (memo, item) ->
          memo[item.code] = item[index]
          memo
        , {})

    build = (data) ->
      _columnDefs = columnDefs(data)
      _labResultsDef = labResultsDef()
      _rowData = rowData(data, _columnDefs, _labResultsDef)
      _lastTestDate = lastTestDate(_columnDefs)
      _abnormalTests = abnormalTests(_columnDefs, _rowData)

      {
      rowData: _rowData,
      columnDefs: _columnDefs,
      lastTestDate: _lastTestDate,
      labResultsDef: _labResultsDef
      abnormalTests: _abnormalTests
      }

    build: build

  .factory 'DateSelectOptions', ->
    buildOptions = ->
      {
      years:  _.map(_.range(1900, 2015), (x) ->
        x.toString()
      )
      months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
      days:   _.map(_.range(1, 32), (x) ->
        x = x.toString()
        x = '0' + x if x.length == 1
        x
      )
      }

    buildBirthdate = (date) ->
      date = moment(date) if date
      {
      year: if date then date.format('YYYY') else ''
      month: if date then date.format('MMMM') else ''
      day: if date then date.format('DD') else ''
      }

    build = (date) ->
      {
      options: buildOptions()
      date: buildBirthdate(date)
      }
