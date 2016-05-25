'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.CqiTasks', ($rootScope, AuthSession, $scope, $state, tasksStatistic, Tasks, Notifications, Treatments, scores, TreatmentDecorator, user, tasksData, newTreatmentsCount, sidebar, sidebarActiveItem, pageCaption) ->
    $scope.user = user
    $scope.newTreatmentsCount = newTreatmentsCount
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    $scope.today = moment({format: "YYYY-MM-DD"})
    $scope.date = moment({format: "YYYY-MM-DD"})

    $scope.user.total_score = scores.total_score
    $scope.user.current_score = scores.current_score

    $scope.collapseItem = (task) ->
      task.isCollapsed = !task.isCollapsed

    findTreatment = (treatmentId) ->
      _.findWhere($scope.treatments, id: parseInt(treatmentId))

    do setVars = (source = tasksData) ->
      $scope.tasks = source.tasks
      $scope.treatments = source.treatments
      $scope.tasksCount = $scope.tasks.length
      $scope.tasksStatistic = tasksStatistic

    do setIsToday = ->
      $scope.isToday = $scope.date.format("YYYY-MM-DD") == $scope.today.format("YYYY-MM-DD")

    do setIsFutureDate = ->
      $scope.isFutureDate = $scope.date > $scope.today

    do prepareTasks = ->
      $scope.tasks = _.map $scope.tasks, (item) ->
        item.data = item.data_completed || findTreatment(item.treatment_id).data
        delete item.data_completed
        item.isCollapsed = true
        item.treatmentDescription = findTreatment(item.treatment_id).description
        item

    $scope.previousDay = ->
      $scope.date = $scope.date.add(-1, 'days')
      $scope.reloadTasks()

    $scope.nextDay = ->
      $scope.date = $scope.date.add(1, 'days')
      $scope.reloadTasks()

    $scope.reloadTasks = ->
      Tasks.list
        date: $scope.date.format('YYYY-MM-DD')
        treatment_receiver_id: user.id
        treatment_status: 'active,completed'
      .then (res) ->
        setVars res.data
        setIsFutureDate()
        setIsToday()
        prepareTasks()

    $scope.applyPoints = (task) ->
      typeStatistic = $scope.tasksStatistic[task.treatment_type]
      if task.is_completed
        $scope.user.current_score += task.points
        typeStatistic.completed++
      else
        $scope.user.current_score -= task.points
        typeStatistic.completed--

    subscriber = if AuthSession.user().role == 'patient'
      AuthSession.user()
    else
      user
    Notifications.subscribeUser(subscriber, (data) ->
      if AuthSession.user().id != data.sender.id
        if $scope.tasks
          $scope.tasks[_.indexOf($scope.tasks, _.filter($scope.tasks, {id: data.data.id})[0])] = data.data
          $scope.applyPoints(data.data)
          prepareTasks()
    ) if AuthSession.isLoggedIn()

    $scope.toggle = (task) ->
      return false if task.disabled
      task.disabled = true
      Tasks.update task.id,
        data_completed: task.data
      .then (res) ->
        task.is_completed = res.data.is_completed
        $scope.applyPoints(task)
        task.disabled = false

    $scope.completeAll = mutexAction $scope, ->
      data = _.map $scope.tasks, (task) ->
        id: task.id,
        is_completed: true
        data_completed: task.data
      Tasks.updateAll collection: data
      .then (res) ->
        _.each $scope.tasks, (task) ->
          unless task.is_completed
            $scope.tasksStatistic[task.treatment_type].completed++
            $scope.user.current_score += task.points
          task.is_completed = true

    $scope.allTaskCompleted = ->
      _.all $scope.tasks, (item) -> item.is_completed

    $scope.getPercentOfTasks = (nameOfType) ->
      statistic = $scope.tasksStatistic[nameOfType]
      if statistic.need == 0
        return "0%"
      else
        "#{Math.floor(statistic.completed / statistic.need * 100)}%"

    $scope.getPercentOfScores = ->
      if $scope.user.total_score == 0
        return "0%"
      else
        "#{ Math.floor($scope.user.current_score / $scope.user.total_score * 100) }%"
