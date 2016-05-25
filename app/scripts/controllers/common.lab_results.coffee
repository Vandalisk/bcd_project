'use strict'

angular.module 'bcd'
  .controller 'ctrl.common.LabResults', ($rootScope, $scope, $localStorage, user, sidebar, sidebarActiveItem, pageCaption, LabResults, LabResultsShaper) ->
    $scope.user = user
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $rootScope.pageCaption = pageCaption
    $scope.diagram = {
      columnDefs: []
    }
    # $scope.diagram = JSON.parse(localStorage.getItem('testObject'))
    $scope.labResults = {}
    $scope.dataLoaded = false

    LabResults.list
      patient_id: user.id
      indicators: [Object.keys(LabResult.INDICATORS)]
    .then (response) ->
      $scope.diagram = LabResultsShaper.build(response.data)
      $scope.dataLoaded = true
      $scope.fill()

      setTimeout fixTableHeight, 1000
      setTimeout agHeaderCell, 1000

    cellRenderer = (params) ->
      item = $scope.diagram.labResultsDef[params.data.code]
      item['maxLevel'] = params.data.maxValue if params.data.maxValue
      item['minLevel'] = params.data.minValue if params.data.minValue

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

      color = 'white' if params.value == 0
      maxHeight = if item and item['maxLevel'] then item['maxLevel']+item['maxLevel']*0.1 else 100

      htmlParts =
        cell: (params, color) ->
          [
            "<div class='cell' highlight-cell row-index-cell='#{params.rowIndex}' column-index-cell='#{params.colDef.columnNumber}'>"
              "<div class='value #{color}'>#{params.value}</div>"
            "</div>"
          ].join ''
        outerLevels: ->
          if item['minLevel'] and item['maxLevel']
            [
              '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%"></div>'
              '<div class="middle-level" style="height:'+((item['maxLevel']-item['minLevel'])/maxHeight*100).toFixed(2)+'%"></div>'
              '<div class="min-level" style="height:'+(item['minLevel']/maxHeight*100).toFixed(2)+'%"></div>'
            ].join ''
          else if item['minLevel']
            [
              '<div class="middle-level" style="height:'+(100 - item['minLevel']/maxHeight*100).toFixed(2)+'%"></div>'
              '<div class="min-level" style="height:'+(item['minLevel']/maxHeight*100).toFixed(2)+'%"></div>'
            ].join ''
          else if item['maxLevel']
            [
              '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%"></div>'
              '<div class="middle-level border-bottom" style="height:'+(item['maxLevel']/maxHeight*100).toFixed(2)+'%"></div>'
            ].join ''
          else
            '<div class="middle-level border-bottom" style="height:100%"></div>'

        dataLevels: ->
          if item['minLevel'] and item['maxLevel']
            if params.value < item['minLevel']
              [
                '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="middle-level" style="height:'+((item['maxLevel']-item['minLevel'])/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="min-level" style="height:'+(item['minLevel']/maxHeight*100).toFixed(2)+'%; margin-bottom:'+(-params.value/maxHeight*140).toFixed(2)+'px"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''
            else if params.value < item['maxLevel']
              [
                '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="middle-level" style="height:'+((item['maxLevel']-params.value)/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''
            else
              [
                '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%; margin-bottom:'+((1-(1-item['maxLevel']/maxHeight)-params.value/maxHeight)*140).toFixed(2)+'px"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''
          else if item['minLevel']
            if params.value < item['minLevel']
              [
                '<div class="middle-level" style="height:'+(100 - item['minLevel']/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="min-level" style="height:'+(item['minLevel']/maxHeight*100).toFixed(2)+'%; margin-bottom:'+(-params.value/maxHeight*140).toFixed(2)+'px"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''
            else
              [
                '<div class="middle-level" style="height:'+(100 - params.value/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''

          else if item['maxLevel']
            if params.value > item['maxLevel']
              [
                '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%; margin-bottom:'+((1-(1-item['maxLevel']/maxHeight)-params.value/maxHeight)*140).toFixed(2)+'px"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''
            else
              [
                '<div class="max-level" style="height:'+(100 - item['maxLevel']/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="middle-level border-bottom" style="height:'+((item['maxLevel']-params.value)/maxHeight*100).toFixed(2)+'%"></div>'
                '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
              ].join ''
          else
            [
              '<div class="middle-level" style="height:'+(100 - params.value/maxHeight*100).toFixed(2)+'%"></div>'
              '<div class="level-value '+color+'" style="height:'+(params.value/maxHeight*100).toFixed(2)+'%"></div>'
            ].join ''

      if params.column.colId is 'code'
        if params.data.visible
          htmlClasses = 'fa-chevron-up expanded-row'
        else
          htmlClasses = 'fa-chevron-down collapsed-row'
        res = [
          '<div class="cell code-name" lab-results-code-cell="'+params.data.code+'" code="" row-index-first-column="'+params.rowIndex+'" highlight-row>'
            '<i ng-click="refreshRow(\''+params.data.code+'\')" class="fa '+htmlClasses+'" toggle-row row-index-i="'+params.rowIndex+'"></i>'
            '<span class="value code-name details-included" data-action="details">'+params.value+'</span>'
          '</div>'
        ].join ''
        height = if params.data.visible then 196 else 36
        $("[row=#{params.rowIndex}]").height(height)
        res
      else
        res = [
          htmlParts.cell params, color
        ]
        if params.data.visible
          res.push('<div class="skill" row-index="'+params.rowIndex+'">'
            '<div class="outer levels first">'
              htmlParts.outerLevels()
            '</div>'
            '<div class="outer levels middle">'
              htmlParts.dataLevels()
            '</div>'
            '<div class="outer levels last">'
              htmlParts.outerLevels()
            '</div>'
          '</div>')
        res.join ''

    _.each $scope.diagram.columnDefs, (field) =>
      field.cellRenderer = cellRenderer

    # fix uncorrect table height
    fixTableHeight= ->
      fullTableHeight = 50 #headerHeight
      _.each $('.ag-body-container').children(), (item) ->
        fullTableHeight += $(item).height()
      e=$(angular.element(document))
      if angular.element(window).width() > 768
        maxTableHeight = e.height() - 165
      else
        maxTableHeight = e.height() - 100
      tableHeight = _.min([fullTableHeight, maxTableHeight])
      $('.wrap-lab-test').height(tableHeight+'px')

    $scope.resetRowsVisibilityData = (rowIndex = -1) ->
      _.each($scope.diagram.rowData, (x, i) ->
        x.visible = i == rowIndex && x.visible
      )

    $scope.refreshRow = (rowCode) ->
      rowIndex = _.indexOf($scope.allCodes, rowCode)
      $scope.resetRowsVisibilityData(rowIndex)
      $scope.labResults.gridOptions.api.onNewRows()

    $scope.initFilter = ->
      $scope.filteredCodes = angular.copy $scope.savedCodes

    $scope.showAllTests = ->
      $scope.resetRowsVisibilityData()
      rowData = $scope.diagram.rowData
      $scope.labResults.gridOptions.api.setRowData rowData
      fixTableHeight()

    $scope.showImportantOnly = ->
      $scope.savedCodes = $localStorage.labResultsSavedCodes
      $scope.resetRowsVisibilityData()
      rowData = _.filter $scope.diagram.rowData, (rec) ->
        _.include $scope.savedCodes, rec['code']
      $scope.labResults.gridOptions.api.setRowData rowData
      fixTableHeight()

    $scope.setFilter = (updateGrid = true) ->
      $scope.savedCodes = $localStorage.labResultsSavedCodes = $scope.filteredCodes
      rowData = _.filter $scope.diagram.rowData, (rec) ->
        _.include $scope.savedCodes, rec['code']
      $scope.labResults.gridOptions.api.setRowData rowData if updateGrid
      $scope.resetRowsVisibilityData()
      fixTableHeight()
      rowData

    $scope.fill = ->
      importantCodes = _.reduce $scope.diagram.labResultsDef, (r, v, k) ->
        r.push k if v.isImportant; r
      , []

      $scope.allCodes = _.keys($scope.diagram.labResultsDef)
      $scope.allCodesInGroups = $scope.allCodes.inGroupsOf(3)

      if $localStorage.labResultsSavedCodes and $localStorage.labResultsSavedCodes.length > 0
        $scope.savedCodes = $localStorage.labResultsSavedCodes
      else
        $scope.savedCodes = importantCodes
      $scope.initFilter()

      rowData = $scope.setFilter(false)

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

      $scope.labResults.gridOptions = gridOptions

    angular.element(window).on 'resize', ->
      fixTableHeight()

    agHeaderCell= ->
      $('.ag-header-cell').on 'mouseover', ->
        highlightColumn this
      $('.ag-header-cell').on 'mouseout', ->
        removelightColumn this

      highlightColumn = (element) ->
        column = $(element).attr('col')
        if column != "0"
          $(element).addClass 'highlighted'
          columnIndex="[column-index-cell=#{column}]"
          $(columnIndex).parent().addClass 'highlighted'

      removelightColumn = (element) ->
        column = $(element).attr('col')
        $(element).removeClass 'highlighted'
        columnIndex="[column-index-cell=#{column}]"
        $(columnIndex).parent().removeClass 'highlighted'

    angular.element(document).ready ->
      setTimeout fixTableHeight, 1000
      setTimeout agHeaderCell, 1000
