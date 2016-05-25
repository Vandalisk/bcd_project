'use strict'

angular.module 'bcd'
  .directive 'access', ($rootScope, AuthSession, Acl, ngIfDirective) ->
    ngIf = ngIfDirective[0];
    transclude: ngIf.transclude
    priority: ngIf.priority
    terminal: ngIf.terminal
    restrict: ngIf.restrict
    link: ($scope, $element, $attr) ->
      $attr.ngIf = ->
        user = AuthSession.user()
        role = user.role
        access = Acl.access[$attr.access]
        if role and access
          return AuthSession.authorize(access, role)
      ngIf.link.apply(ngIf, arguments);


  .directive 'selectOnClick', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      $(element).on 'focus, click', ->
        this.select()

  .directive 'toggleMenu', ($rootScope, $window) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      openMenu = ->
        $('main .wrap .sidebar').addClass('open')
        $('body').addClass('menu-open')
        # $('body').append('<div class="menu-overlay"></div>')
      closeMenu = ->
        $('main .wrap .sidebar').removeClass('open')
        $('body').removeClass('menu-open')
        # $('.menu-overlay').remove()
      toggleMenu = ->
        if $('main .wrap .sidebar').hasClass('open') then closeMenu() else openMenu()
      element.on 'click', -> toggleMenu()
      $($window).on 'resize', ->
        closeMenu() if $($window).width() > 768
      $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) -> closeMenu()
      $rootScope.$on '$dialog:opened', (event, dialog) -> closeMenu()


  .directive 'toggleSearch', ($rootScope, $timeout) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      $('.navbar').on 'click', '[toggle-search-open]', ->
        $rootScope.showSearch = true
        scope.$apply()
        $timeout ->
          $('.search-form input').focus()

      $('.navbar').on 'click', '[toggle-search-close]', ->
        $rootScope.showSearch = false
        scope.$apply()

      $('.search-form input').bind 'keyup', (e) ->
        if e.keyCode == 27
          $rootScope.showSearch = false
          scope.$apply()

  .directive 'treatmentForm', ($q, Treatments, TreatmentTemplates, TreatmentDecorator) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.searchTreatmentTemplatesNames = (val) ->
        TreatmentTemplates.list
          q: val,
          per_page: 10
          order: 'full_name'
        .then (res) ->
          _.map res.data.collection, (item) ->
            item.full_name = TreatmentDecorator.fullName(item)
            item.total_points = TreatmentDecorator.calculatedPoints(item)
            item


  .directive 'interactiveTreatmentsTable', ($state, $dialog, $uibModal, $filter, $templateCache, Treatments, Notification, TreatmentDecorator) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.activeItem = `undefined`

      scope.setActiveItem = (item) ->
        scope.activeItem = item

      scope.isActiveItem = (item) ->
        scope.activeItem and scope.activeItem.id is item.id

      scope.details = ->
        $dialog
          closeOnEscape: true
          html: true
          content: [
            "<h4>#{scope.activeItem.name}</h4>"
            "<p>#{$filter('nl2br')(scope.activeItem.description)}</p>"
          ].join('\n')

      # scope.edit = ->
      #   modalInstance = $uibModal.open(
      #     templateUrl: 'app/templates/doctor/cqi_treatments/_form.html',
      #     controller: 'ctrl.doctor.approveRequestTreatment',
      #     resolve:
      #       user: scope.user,
      #       treatment: scope.activeItem
      #   )

      scope.edit = ->
        $state.go 'doctor.patients.item.cqi_treatments.edit', userId: scope.user.id, treatmentId: scope.activeItem.id

      scope.remove = ->
        Treatments.update scope.activeItem.id, status: 'declined'
        .success (data) ->
          Notification.success("#{scope.activeItem.name} was moved to history")
          scope.treatments[_.indexOf(scope.treatments, _.find(scope.treatments, {id: item.id}))] = item
          scope.prepareTreatments()
          scope.activeItem = `undefined`
          scope.$apply()

      scope.updateStatus = mutexAction scope, ->
        name = scope.activeItem.name
        Treatments.update scope.activeItem.id, status: scope.status
        .success (data) ->
          item = data.item
          item.model = new Treatment(item)
          if item.treatment_type == 'medication_tablets' || item.treatment_type == 'medication_injection'
            _.each item.data.schedule, (v, k) ->
              item.data.schedule[k] = parseFloat(v)

          scope.treatments[_.indexOf(scope.treatments, _.find(scope.treatments, {id: item.id}))] = item
          scope.prepareTreatments()
          scope.activeItem = `undefined`
          if scope.status is 'declined'
            Notification.success("#{name} was moved to history")
          else if scope.status is 'active'
            Notification.success("#{name} was moved to current")

      scope.changeRequestedTreatment = ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/templates/doctor/cqi_treatments/_current_treatment_form.html',
          controller: 'ctrl.common.changeRequestTreatment',
          windowClass: 'prescription-form-dialog',
          size: 'prescription-form-dialog',
          resolve:
            scope: scope,
            updateList: => scope.prepareTreatments
        )

      scope.declineTreatment = ->
        treatments = scope.treatments
        modalInstance = $uibModal.open(
          templateUrl: 'app/templates/doctor/cqi_treatments/_decline_treatment_form.html',
          controller: 'ctrl.common.declineRequestTreatment',
          size: 'lg',
          resolve:
            scope: scope,
            updateList: => scope.prepareTreatments
        )


      scope.allowAction = (action) ->
        return false unless scope.activeItem
        allow = false
        if action is 'details'
          allow = true if scope.activeItem.description
        else if _.indexOf(['edit', 'remove', 'accept'], action) >= 0
          allow = true if scope.activeItem.status is 'new' or scope.activeItem.status is 'requested'
        else if action is 'deactivate'
          allow = true if scope.activeItem.status is 'active'
        else if action is 'reactivate'
          allow = true if scope.activeItem.status is 'declined' or scope.activeItem.status is 'stopped'
        else if action is 'requestchange'
          allow = true if scope.activeItem.status is 'active'
        else if action is 'doctordecline'
          allow = true if scope.activeItem.status is 'requested'
        allow

      scope.$watch 'activeItem', (item) ->
        items = scope.$eval(attrs.interactiveTreatmentsTable)
        idInList = item and !!_.findWhere(items, {id: item.id})

        _.each element.find('.table-actions').find('[data-action]'), (item) ->
          action = $(item).data('action')
          if idInList && scope.allowAction(action)
            $(item).addClass('active')
          else
            $(item).removeClass('active')

      element.on 'click', '[data-action="details"]', ->
        scope.details() if scope.allowAction "details"

      element.on 'click', '[data-action="edit"]', ->
        scope.edit() if scope.allowAction "edit"

      element.on 'click', '[data-action="remove"]', ->
        scope.remove() if scope.allowAction "remove"

      element.on 'click', '[data-action="accept"]', ->
        scope.status = 'active'
        scope.updateStatus(scope) if scope.allowAction "accept"

      element.on 'click', '[data-action="decline"]', ->
        scope.declineTreatment()

      element.on 'click', '[data-action="cancel"]', ->
        scope.status = 'declined'
        scope.updateStatus(scope)

      element.on 'click', '[data-action="deactivate"]', ->
        scope.status = 'stopped'
        scope.updateStatus(scope) if scope.allowAction "deactivate"

      element.on 'click', '[data-action="reactivate"]', ->
        scope.status = 'active'
        scope.updateStatus(scope) if scope.allowAction "reactivate"

      element.on 'click', '[data-action="requestchange"]', ->
        scope.changeRequestedTreatment() if scope.allowAction "requestchange"

  .directive 'button', ->
    restrict: 'E'
    link: (scope, element, attrs) ->
      element.on 'click', ->
        @blur()

  .directive 'pplink', ($uibModal) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      scope.pointsHint = ->
        modalInstance = $uibModal.open(
          templateUrl: 'app/templates/doctor/cqi_treatment_templates/_form.points_hint.html',
          controller: 'ctrl.doctor.pointsHint',
          windowClass: 'points-hint',
          size: 'points-hint',
          resolve:
            scope: scope
        )

      element.on 'click', ->
        scope.pointsHint()

  .directive 'treatmentFormHeader', ->
    restrict: 'A'
    templateUrl: 'app/templates/doctor/cqi_treatments/_form_header.html'

  .directive 'treatmentEdit', ($popover, $timeout, TreatmentMedicationSchedule) ->
    restrict: 'A'
    scope:
      rootItem: '=treatmentEdit'
    link: (scope, element, attrs) ->
      editDosagePopover = `undefined`
      editSchedulePopover = `undefined`

      scope.scheduleSelected = ->
        scope.item.data.schedule and _.filter(scope.item.data.schedule, (v,k) -> v > 0).length > 0

      scope.saveDosage = ->
        editDosagePopover.$promise.then(editDosagePopover.hide)
        scope.rootItem.data.dosage = scope.item.data.dosage

      scope.saveSchedule = ->
        editSchedulePopover.$promise.then(editSchedulePopover.hide)
        scope.rootItem.data.schedule = scope.item.data.schedule

      scope.closeEditDosagePopover = ->
        if editDosagePopover and editDosagePopover.$isShown
          editDosagePopover.$promise.then(editDosagePopover.hide)

      scope.closeEditSchedulePopover = ->
        if editSchedulePopover and editSchedulePopover.$isShown
          editSchedulePopover.$promise.then(editSchedulePopover.hide)

      element.livequery '[data-edit="item.data.dosage"]', (elem) ->
        $(elem).on 'click', (e) ->
          scope.closeEditSchedulePopover()
          return if editDosagePopover and editDosagePopover.$isShown
          scope.item = angular.copy scope.rootItem

          editDosagePopover = $popover angular.element(this),
            template: 'app/templates/doctor/cqi_treatments/_form_edit_dosage.html'
            placement: 'bottom'
            trigger: 'manual'
            scope: scope
          editDosagePopover.$promise.then ->
            editDosagePopover.show()
            $timeout -> element.find('.popover').find('input').focus().select()

      element.livequery '[data-edit^="item.data.schedule"]', (elem) ->
        $(elem).on 'click', (e) ->
          scope.closeEditDosagePopover()
          return if editSchedulePopover and editSchedulePopover.$isShown
          scope.item = angular.copy scope.rootItem
          scope.item.data.schedule = TreatmentMedicationSchedule.prepareValues(scope.item.data.schedule)
          editSchedulePopover = $popover angular.element(this),
            template: 'app/templates/doctor/cqi_treatments/_form_edit_schedule.html'
            placement: 'bottom'
            trigger: 'manual'
            scope: scope
          editSchedulePopover.$promise.then ->
            editSchedulePopover.show()
            attr = $(e.target).attr('data-edit')
            $timeout -> element.find('.popover').find('[ng-model="' + attr + '"]').focus().select()

      $(document).keyup (e) ->
        if e.keyCode == 27
          scope.closeEditDosagePopover()
          scope.closeEditSchedulePopover()


  .directive 'syncExport', ($http, $timeout, $interval) ->
    restrict: 'A'
    templateUrl: 'app/templates/doctor/_cqi_export_to_csv.html'
    link: (scope, element, attrs) ->

      scope.data =
        percent: 0
        done_count: 0
        done: false
        abort: false

      showError = (error) ->
        scope.data.abort = true
        scope.data.done = true
        scope.data.error = "Unexpected error"

      scope.start = (options) ->
        $http.post "#{appConfig.urlApi}/sync/exports", options
        .success (data) ->
          if data.success && data.url
            process data.url
        .error (data) ->
          showError "Unexpected error"

      process = (url) ->
        $http.post url, {}
        .success (data) ->
          if data.success && !isNaN(data.total_count) && !scope.data.abort
            scope.data.done_count = data.done_count
            # scope.data.percent = data.done_count * 100 / data.total_count
            # scope.data.percent = 100 if isNaN(scope.data.percent)
            if data.url
              scope.data.done = true
              scope.data.downloadUrl = data.url
              $timeout -> $('.download-link a')[0].click()
            else
              process url
          else
            showError "Unexpected error"
        .error (data) ->
          showError "Unexpected error"

      if attrs.autostart
        scope.start
          what: 'tasks'


  # .directive 'testTimer', ($http, $timeout, $interval) ->
  #   restrict: 'A'
  #   templateUrl: 'app/templates/doctor/cqi/_export_to_csv.html'
  #   link: (scope, element, attrs) ->
  #     scope.data ||= {}

  #     update = ->
  #       scope.data = angular.extend scope.data, {date: new Date()}
  #       # log scope.data.date

  #     timer = $interval update, 1000

  #     element.on '$destroy', ->
  #       $interval.cancel timer

  .directive 'treatmentSearch', ->
    restrict: 'A'
    templateUrl: "/app/templates/common/cqi_treatment_templates/_helper_filters.html"
    link: (scope, element, attrs) ->
      scope.filters = {}
      scope.selected = ''
      scope.selectedFilter = ''

      scope.impactTypes = [
        'high_a1c',
        'cholesterol/apob',
        'high_blood_pressure',
        'other'
      ]
      scope.treatmentTypesFilter = [
        'medication_tablets',
        'medication_injection',
        'exercise',
        'diet',
        'lifestyle'
      ]
      scope.impactColor =
        'high_a1c': 'pink'
        'cholesterol/apob': 'light-blue'
        'high_blood_pressure': 'salad-green'
        'other': 'liliac'

      scope.determineColor = (impact) ->
        scope.impactColor[impact]

      scope.filterSelected = (impact) ->
        scope.filters.impact = impact
        scope.selectedFilter = impact

      scope.selectType = (type) ->
        scope.filters.treatment_type = type
        scope.selected = type

  .directive 'togglePasswordText', ->
    restrict: 'A'
    scope:
      showSymbols: '=togglePasswordText'
    link: (scope, element, attrs) ->
      scope.$watch "showSymbols", (value) ->
        element[0].type = (if scope.showSymbols then "text" else "password")


  .directive 'autocompleteSearchUsers', ($state, $rootScope, Users) ->
    restrict: 'A'
    # require: '^ngModel'
    # link: (scope, element, attrs, ngModel) ->
    link: (scope, element, attrs) ->
      if attrs.tpl is 'header.users'
        tpl = _.template('
          <div class="name"><%= full_name %></div>
          <div class="role"><%= role %></div>
          <div class="info ava role-<%= role %>"><img src="<%= gravatar_url + \"&s=30\" %>" /></div>
          <div class="info"><%= birthday %></div>
          <div class="info"><%= email %></div>
          <div class="info"><%= phone %></div>
        ')
      else if attrs.tpl is 'sidebar.users'
        tpl = _.template('
          <div class="ava role-<%= role %>"><img src="<%= gravatar_url + \"&s=30\" %>" /></div>
          <div class="info">
            <span class="name"><%= full_name %></span>
            <span><%= birthday %></span>
            <!--<span><%= email %></span>-->
            <span><%= phone %></span>
            <span class="role"><%= role %></span>
          </div>
        ')

      reset = ->
        element.typeahead 'val', ''
        element.typeahead 'close'
        $rootScope.showSearch = false

      element.typeahead
        minLength: 0
        highlight: true
        hint: false
      ,
        source: (query, cb) ->
          Users.list
            q: query,
            per_page: 10
          .then (res) ->
            cb res.data.collection
        displayKey: 'full_name'
        templates:
          suggestion: tpl
          empty: [
            '<div class="empty">'
              '<p>No profiles were found</p>',
              '<p><button class="btn btn-primary btn-default" data-action="add-user">Create user</button></p>',
            '</div>'
          ].join('\n')

      element.on 'typeahead:selected', (event, item) ->
        reset()
        if item.role is 'patient'
          $state.go 'doctor.patients.item.dashboard', userId: item.id
        else
          $state.go 'doctor.doctors.item.dashboard', userId: item.id
        scope.$apply()

      element.on 'typeahead:opened', ->
        initial = element.val()
        ev = $.Event 'keydown'
        ev.keyCode = ev.which = 40
        element.trigger ev
        element.val '' if element.val() isnt initial

      element.on 'typeahead:opened', ->
        element.closest('form').addClass 'typeahead-opened'

      element.on 'typeahead:closed', ->
        element.closest('form').removeClass 'typeahead-opened'

      $(document).on 'click', '.tt-dropdown-menu .empty [data-action="add-user"]', ->
        reset()
        $state.go 'doctor.add_user'
        scope.$apply()


  .directive 'autocompleteTreatmentTemplatesNames', (TreatmentTemplates, $filter) ->
    restrict: 'A'
    require: '^ngModel'
    link: (scope, element, attrs, ngModel) ->

      used_treatment_template_ids = []
      do setUsedTreatmentTemplateIds = (treatments = scope.treatments)->
        used_treatment_template_ids = _.uniq _.map treatments, (item) -> item.treatment_template_id

      scope.$watch 'treatments', (treatments) ->
        setUsedTreatmentTemplateIds(treatments)

      prepareItems = (items) ->
        _.map items, (item) ->
          if _.indexOf(used_treatment_template_ids, item.id) >= 0
            used_treatment = _.findWhere scope.treatments, treatment_template_id: item.id
            item.css_class = "inactive"
            status = used_treatment.status
            status = 'suggested' if used_treatment.status is 'new'
            status = "active (#{$filter('number')(used_treatment.completion_percent, 2)}%)" if used_treatment.status is 'active'
            item.full_name = "#{item.name}: #{status}"
          else
            item.css_class = ""
          item

      element.typeahead
        minLength: 0
        highlight: true
        hint: false
      ,
        source: (query, cb) ->
          TreatmentTemplates.list
            q: query,
            per_page: 10
            order: 'full_name'
          .then (res) ->
            items = prepareItems res.data.collection
            cb items
        displayKey: 'full_name'
        templates:
          suggestion: _.template('<p class="<%= css_class %>"><%= full_name %></p>')

      element.on 'typeahead:selected', (event, item) ->
        return if _.indexOf(used_treatment_template_ids, item.id) >= 0
        ngModel.$setViewValue element.typeahead('val')
        scope.$emit 'typeahead:selected', item
        scope.$apply()

      element.on 'typeahead:opened', ->
        initial = element.val()
        ev = $.Event 'keydown'
        ev.keyCode = ev.which = 40
        element.trigger ev
        element.val '' if element.val() isnt initial


  .directive 'dialogMessagesList', ($rootScope, $timeout) ->
    restrict: 'A'
    scope: false
    link: (scope, element, attrs) ->
      el = element.find('[scroll-y]')[0]
      # window.tt = el

      # scroll to bottom
      scrollBottom = ->
        el.scrollTop = el.scrollHeight

      # mark unread messages as read when they appear on view area
      markAsRead = ->
        ids = _.compact(_.map($('.item.unread:not(.mine)'), (x) ->
          parseInt($(x).attr('data-id')) if $(x).visible()
        ))
        if _.any(ids)
          scope.readMultiple {message_ids: ids}

      $rootScope.$on 'dialogMessages.loadInitial', (event) ->
        $timeout ->
          unreadMessages = element.find('.item.unread:not(.mine)')
          if unreadMessages.length > 0
            $(el).scrollTo element.find('.item.unread:not(.mine)')[0],
              offsetTop: 160
              duration: 0
          else
            scrollBottom()
          markAsRead()

      $rootScope.$on 'dialogMessages.messageAdded', (event, data, options) ->
        $timeout ->
          scrollBottom() if scope.data.stickToBottom or (options and options.forceStickToBottom)

      # load old messages when scroll to top
      $(el).on 'scroll', _.throttle ->
        elOuterHeight = $(el).outerHeight()
        # scroll to top
        if el.scrollTop is 0
          $rootScope.$emit 'dialogMessages.scrollTop'

        # scroll to bottom
        if el.scrollTop >= (el.scrollHeight - elOuterHeight - 10)
          scope.data.stickToBottom = true
          $rootScope.activeDialogWith = scope.activeItem.id
        else
          scope.data.stickToBottom = false
          $rootScope.activeDialogWith = `undefined`

        scope.$apply()
      , 1000


      $(el).on 'scroll', _.throttle markAsRead, 1000, leading: false


  .directive 'labResults', ($dialog) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      filterDialog = undefined

      scope.showFilterDialog = ->
        scope.initFilter()
        filterDialog = $dialog
          closeOnEscape: true
          scope: scope
          template: "/app/templates/common/_lab_results.filter.html"

      scope.closeFilterDialog = ->
        filterDialog.close()

      element.on 'click', '[data-action="showFilterDialog"]', ->
        scope.showFilterDialog()

      element.on 'click', '[data-action="showAllTests"]', ->
        $('.wrap-all-tests').hide()
        $('.wrap-important-only').show()
        scope.showAllTests()

      element.on 'click', '[data-action="showImportantOnly"]', ->
        $('.wrap-important-only').hide()
        $('.wrap-all-tests').show()
        scope.showImportantOnly()

      $(document).on 'click', '.lab-results-filter [data-action="closeFilterDialog"]', ->
        scope.closeFilterDialog()

      $(document).on 'click', '.lab-results-filter [data-action="setFilter"]', ->
        scope.setFilter()
        scope.closeFilterDialog()


  .directive 'toggleRow', ($rootScope, $window) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      fixTableHeight= ->
        fullTableHeight = 50 #headerHeight
        _.each $('.ag-body-container').children(), (item) ->
          fullTableHeight += $(item).height()
        e=$(angular.element(document))
        maxTableHeight = e.height() - 165
        tableHeight = _.min([fullTableHeight, maxTableHeight])
        $('.wrap-lab-test').height(tableHeight+'px')

      toggleFunc = (rIndex = attrs['rowIndexI']) ->
        height = if scope.data.visible then 196 else 36
        setTimeout( ->
          $("[row=#{rIndex}]").height(height)
          fixTableHeight()
        , 200)

      toggleRow = ->
        scope.data.visible = !scope.data.visible
        toggleFunc()

      element.on 'click', -> toggleRow()


  .directive 'highlightCell', ($rootScope, $window) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      highlightCell = ->
        rowIndex=".ag-pinned-cols-container [row=#{attrs['rowIndexCell']}]"
        columnIndex=".ag-header-cell[col=#{attrs['columnIndexCell']}]"
        $(rowIndex).addClass 'highlighted'
        $(columnIndex).addClass 'highlighted'
        element.parent().addClass 'highlighted'

      removelightCell = ->
        rowIndex=".ag-pinned-cols-container [row=#{attrs['rowIndexCell']}]"
        columnIndex=".ag-header-cell[col=#{attrs['columnIndexCell']}]"
        $(rowIndex).removeClass 'highlighted'
        $(columnIndex).removeClass 'highlighted'
        element.parent().removeClass 'highlighted'

      element.on 'mouseover', -> highlightCell()
      element.on 'mouseout', -> removelightCell()


  .directive 'highlightRow', ($rootScope, $window) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      highlightRow = ->
        rowIndex="[row-index-cell=#{attrs['rowIndexFirstColumn']}]"
        $(rowIndex).parent().addClass 'highlighted'
        element.parent().addClass 'highlighted'

      removelightRow = ->
        rowIndex="[row-index-cell=#{attrs['rowIndexFirstColumn']}]"
        $(rowIndex).parent().removeClass 'highlighted'
        element.parent().removeClass 'highlighted'

      element.on 'mouseover', -> highlightRow()
      element.on 'mouseout', -> removelightRow()


  .directive 'labResultsCodeCell', ($dialog, $filter) ->
    restrict: 'A'
    link: (scope, element, attrs) ->

      scope.details = ->
        k = attrs["labResultsCodeCell"]
        try
          v = scope.diagram.labResultsDef[k]
          return if !v.nameFull or !v.description
          $dialog
            closeOnEscape: true
            html: true
            content: [
              "<h4>#{v.nameFull}</h4>"
              "<p>#{$filter('nl2br')(v.description)}</p>"
            ].join ''

      element.on 'click', '[data-action="details"]', ->
        scope.details()


  .directive 'toggleFullTableLabResults', ($rootScope, $window) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      fixTableHeight= ->
        fullTableHeight = 50 #headerHeight
        _.each $('.ag-body-container').children(), (item) ->
          fullTableHeight += $(item).height()
        e=$(angular.element(document))
        maxTableHeight = e.height() - 100
        tableHeight = _.min([fullTableHeight, maxTableHeight])
        $('.wrap-lab-test').height(tableHeight+'px')

      showFullTable = ->
        mobileVersion = $('.wrap-mobile-version')
        fullVersion = $('.wrap-lab-test')

        fixTableHeight()

        mobileVersion.addClass('hide')
        fullVersion.addClass('visible')

      element.on 'click', -> showFullTable()

  .directive 'togglePanelDashboard', ($rootScope, $window) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      expandPanel = ->
        element.addClass 'fa-chevron-down'
        element.addClass 'expanded-panel'
        element.removeClass 'fa-chevron-up'
        element.removeClass 'collapsed-panel'
        element.parents('.panel').children('.panel-body').hide()

      collapsePanel = () ->
        element.addClass 'fa-chevron-up'
        element.addClass 'collapsed-panel'
        element.removeClass 'fa-chevron-down'
        element.removeClass 'expanded-panel'
        element.parents('.panel').children('.panel-body').show()

      collapsePanels = () ->
        _.each $('.expanded-panel'), (item) ->
          e = $(item)
          e.addClass 'fa-chevron-up'
          e.addClass 'collapsed-panel'
          e.removeClass 'fa-chevron-down'
          e.removeClass 'expanded-panel'
          e.parents('.panel').children('.panel-body').show()

      togglePanel = ->
        if element.hasClass('expanded-panel') then collapsePanel() else expandPanel()

      element.on 'click', -> togglePanel()
      $($window).on 'resize', ->
        collapsePanels() if $($window).width() > 768

  .directive 'bgPopup', ($rootScope, $window, $uibModal, BloodGlucoses) ->
    restrict: 'E'
    replace: true
    transclude: true
    templateUrl: '/app/templates/common/blood_glucose/_popover_window.html'
    scope:
      schedule: '='
      obj: '='
      patientId: '='
    link: ($scope, element, attrs) ->
      $scope.openModal = ->
        modalInstance = $uibModal.open(
          templateUrl: '/app/templates/common/blood_glucose/_form_modal.html',
          controller: 'ctrl.common.bloodGlucoseModal',
          size: 'sm',
          resolve:
            scope: $scope
        )

      $scope.clear = ->
        if $scope.obj.id
          BloodGlucoses.destroy(
            $scope.obj.id
          ).success (data) ->
            $scope.obj.value = '+'
            delete($scope.obj.id)
        else
          $scope.obj.value = '+'

      $scope.openModal() if $scope.obj.value == '+'

  .directive 'fixTableWidth', ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      fixWidth = ->
        element.find('.ag-header-viewport').css("width", "100%")
        cloneOfLastHeader = element.find('.ag-header-container > .ag-header-cell:last-child').clone()
        cloneOfLastHeader.attr({
          col: parseInt(cloneOfLastHeader.attr("col")) + 1,
          colid: ""
        })
        cloneOfLastHeader.find('.ag-header-cell-text').text('')
        cloneOfLastHeader.css("width", "100%")
        cloneOfLastHeader.appendTo($('.ag-header-container'))
        element.find('.ag-body-container').css('width','100%').find('.ag-row').css('width', '100%')

      fixWidth() if parseInt(attrs.fixTableWidth) < 11
  .directive 'compile', ($compile) ->
    link: (scope, element, attrs) ->
      scope.$watch ((scope) ->
        scope.$eval attrs.compile
      ), (value) ->
        element.html value
        $compile(element.contents()) scope
