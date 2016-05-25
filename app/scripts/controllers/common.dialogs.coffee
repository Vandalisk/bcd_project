'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.Dialogs', ($rootScope, $scope, $state, $timeout, $filter, Faye, DialogMessages, Messages, user, dialogs_messages, sidebar, sidebarActiveItem, pageCaption) ->
    $scope.user = user
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    $scope.dialogs = `undefined`
    $scope.activeItem = `undefined`
    $scope.data = {}
    $scope.messages = `undefined`
    timer = `undefined`

    listDialogs = ->
      items = $scope.dialogs
      if $rootScope.currentUser.role is 'admin' or $rootScope.currentUser.role is 'doctor' or $rootScope.currentUser.role is 'case_manager'
        if $scope.data.search
          items = $filter('filter')(items, $scope.data.search)

      if $rootScope.currentUser.role is 'patient'
        items = $filter('inArray')(items, ['admin', 'doctor', 'case_manager'], 'role')
        if $scope.data.search
          items = $filter('filter')(items, $scope.data.search)

      $scope.filteredDialogs = items

    dialogs = dialogs_messages.dialogs
    _.each dialogs, (dialog) ->
      message = _.findWhere dialogs_messages.messages, id: dialog.message_id
      dialog.message = message if message
    $scope.dialogs = dialogs
    listDialogs()

    $scope.states = ->
      base_state = 'dialogs'
      list: "#{base_state}.list"
      item: "#{base_state}.item"

    $scope.toggleActiveItem = (item) ->
      if parseInt($state.params.receiverId) is item.id
        $state.go $scope.states().list
      else
        $state.go $scope.states().item, receiverId: item.id

    isInActiveDialog = (data) ->
      $scope.activeItem and ($scope.activeItem.id is data.sender_id or $scope.activeItem.id is data.receiver_id)

    isMine = (data) ->
      data.sender_id is $rootScope.currentUser.id

    isStickToBottom = (data) ->
      $scope.data.stickToBottom

    isAutoUpdate = (data) ->
      isInActiveDialog(data) and isStickToBottom(data) and !isMine(data)

    addMessage = (data) ->
      # log "addMessage"
      # log data
      data.is_read = true if isAutoUpdate(data)
      counter = if isAutoUpdate(data) then 0 else 1

      if isInActiveDialog(data)
        items = [data]
        items = DialogMessages.prepareMessages $scope, items
        items = ($scope.messages || []).concat items
        $scope.messages = DialogMessages.groupMessages $scope, items
        DialogMessages.setFirstAndLastIds $scope

      updateDialogs data, "add", counter

      $scope.update data.id, is_read: true if isAutoUpdate(data)

    updateMessage = (data) ->
      # log "updateMessage"
      # log data
      item = _.findWhere ($scope.messages || []), id: data.id
      counter = if item and !item.is_read and data.is_read then -1 else 0
      _.extend item, data
      updateDialogs data, "update", counter

    updateDialogs = (data, action, counter) ->
      user_id = if isMine(data) then data.receiver_id else data.sender_id
      dialog = _.findWhere $scope.dialogs, id: user_id
      if dialog
        if action is "add"
          dialog.message = data
          dialog.message_id = data.id
        else if action is "update"
          _.extend dialog.message, data if dialog.message and dialog.message.id is data.id
        dialog.unread_messages_count += counter if !isMine(data)

        dialogIndex = _.indexOf(dialogs, dialog)
        dialogs.move(dialogIndex, 0) if dialogIndex > 0
        listDialogs()

    $scope.$watch 'currentState.params', ->
      $scope.activeItem = _.findWhere $scope.dialogs, id: parseInt($state.params.receiverId)
      if $scope.activeItem
        $rootScope.pageCaption = $scope.activeItem.full_name
        # $scope.data.stickToBottom = true
        $rootScope.activeDialogWith = $scope.activeItem.id
        DialogMessages.loadInitial $scope
        $scope.data.text = ''
      else
        $scope.messages = `undefined`
        $rootScope.pageCaption = 'Messages'
        $rootScope.activeDialogWith = `undefined`

    $scope.$watch 'data.search', (val) -> listDialogs()

    $rootScope.$on 'dialogMessages.scrollTop', (event) ->
      DialogMessages.loadOld $scope

    $rootScope.$on 'dialogMessages.messageReceived', (event, data) ->
      if data.new_item
        addMessage data.new_item
        $timeout -> $rootScope.$emit 'dialogMessages.messageAdded', data.new_item
      else if data.updated_item
        updateMessage data.updated_item
        $timeout -> $rootScope.$emit 'dialogMessages.messageUpdated', data.updated_item
      else if data.updated_item_ids
        messages = _.filter $scope.messages, (x) ->
          _.include(data.updated_item_ids, x.id)
        _.each messages, (msg) ->
          msg.is_read = true
          updateMessage msg
          $timeout -> $rootScope.$emit 'dialogMessages.messageUpdated', msg

    $scope.isActive = (item) ->
      $scope.activeItem and $scope.activeItem.id is item.id

    $scope.submit = mutexAction $scope, ->
      text = $scope.data.text
      $scope.data.text = ''
      Messages.create
        receiver_id: $scope.activeItem.id
        text: text
      .success (data) ->
        $scope.data.text = ''
        addMessage data.new_item
        $timeout -> $rootScope.$emit 'dialogMessages.messageAdded', data.new_item, forceStickToBottom: true

    $scope.update = (id, data) ->
      Messages.update id, data
      .success (data) ->
        updateMessage data.updated_item
        $timeout -> $rootScope.$emit 'dialogMessages.messageUpdated', data.updated_item

    $scope.readMultiple = (data) ->
      Messages.readMultiple data
      .success (data) ->
        messages = _.filter $scope.messages, (x) ->
          _.include(data.updated_item_ids, x.id)
        _.each messages, (msg) ->
          msg.is_read = true
          updateMessage msg
          $timeout -> $rootScope.$emit 'dialogMessages.messageUpdated', msg
