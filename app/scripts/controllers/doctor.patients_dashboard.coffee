'use strict'

angular.module 'bcd'
  .controller 'ctrl.doctor.PatientsDashboard', ($rootScope, $scope, $localStorage, $filter, ActivePatient, user, treatments, sidebar, sidebarActiveItem, pageCaption, LabResults, LabResultsShaper) ->
    $scope.user = user
    $scope.treatments = treatments
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption

    ActivePatient.set user.id
    $rootScope.activePatient = user
    $rootScope.showSearch = false
    $scope.dataLoaded = false

    do $scope.prepareTreatments = ->
      items = $filter('filter')($scope.treatments, {status: 'requested'})
      items = $filter('orderBy')(items, 'created_at')
      $scope.requestedTreatments = items

      items = $filter('filter')($scope.treatments, {status: 'active'})
      items = $filter('orderBy')(items, 'date_start')
      $scope.activeTreatments = items

    LabResults.list
      patient_id: user.id
      indicators: [Object.keys(LabResult.INDICATORS)]
    .then (response) ->
      $scope.diagram = LabResultsShaper.build(response.data)
      $scope.dataLoaded = true
      cellRenderer = (params) ->
        item = $scope.diagram.labResultsDef[params.data.code]
        if item
          if item['minLevel'] and item['maxLevel']
            color = if params.value >= item['minLevel'] and params.value <= item['maxLevel'] then 'green' else 'red'
          else if item['minLevel']
            color = if params.value >= item['minLevel'] then 'green' else 'red'
          else if item['maxLevel']
            color = if params.value <= item['maxLevel'] then 'green' else 'red'
          else
            color = 'green'
        else
          color = 'green'

        if params.column.colId is 'code'
          [
            "<div class='cell code-name'>"
              "<span class='value code-name'>#{params.value}</span>"
            "</div>"
          ].join ''
        else
          [
            "<div class='cell'>"
              "<div class='value #{color}'>#{params.value}</div>"
            "</div>"
          ].join ''

      _.each $scope.diagram.columnDefs, (field) =>
        field.cellRenderer = cellRenderer

      importantCodes = _.reduce $scope.diagram.labResultsDef, (r, v, k) ->
        r.push k if v.isImportant; r
      , []

      if $localStorage.labResultsSavedCodes and $localStorage.labResultsSavedCodes.length > 0
        savedCodes = $localStorage.labResultsSavedCodes
      else
        savedCodes = importantCodes

      rowData = _.filter $scope.diagram.rowData, (rec) ->
        _.include savedCodes, rec['code']

      gridOptions =
        columnDefs: $scope.diagram.columnDefs
        rowData: rowData
        pinnedColumnCount: 1
        angularCompileRows: true
        rowSelection: 'multiple'
        enableColResize: false
        enableSorting: false
        enableFilter: false
        groupHeaders: false
        rowHeight: 36
        headerHeight: 50

      $scope.labResults =
        labResultsCount: $scope.diagram.columnDefs.length
        abnormalTests: $scope.diagram.abnormalTests
        lastTestDate: $scope.diagram.lastTestDate
        gridOptions: gridOptions

      $scope.setFilter = (updateGrid = true) ->
        $scope.savedCodes = $localStorage.labResultsSavedCodes = $scope.filteredCodes
        rowData = _.filter $scope.diagram.rowData, (rec) ->
          _.include $scope.savedCodes, rec['code']
        $scope.labResults.gridOptions.api.setRowData rowData if updateGrid
        fixTableHeight()
        rowData

    # fix uncorrect table height
    fixTableHeight= ->
      fullTableHeight = 50 #headerHeight
      _.each $('.ag-body-container').children(), (item) ->
        fullTableHeight += $(item).height()
      $('.wrap-lab-test').height(fullTableHeight+'px')

    angular.element(document).ready ->
      setTimeout fixTableHeight, 1000
