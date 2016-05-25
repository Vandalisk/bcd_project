'use strict'

angular.module 'bcd'
  .factory 'TreatmentMedicationTabletsDecorator', ->
    options =
      masterSteps: ['name', 'type', 'schedule', 'description']
      captionNextStep: 'Proceed to dosage form'
      scheduleOptions: ['before', 'with', 'after']
      units: [
        {key: 'mg tabs', name: 'mg', unit: 'mg tabs', action: 'take', thing: 'tabs'}
        {key: 'micrograms', name: 'micrograms', unit: 'micrograms', action: 'take', thing: 'tabs'}
      ]

    conditionText: (item, small, html) ->
      selectedUnit = _.findWhere(options.units, key: item.data.unit)
      unit = selectedUnit.unit
      action = selectedUnit.action
      thing = selectedUnit.thing
      schedule = []
      _.each item.data.schedule, (v, k) ->
        when_value = if k is 'bedtime' then 'at' else item.data.when
        if html
          schedule.push "<span ng-class=\"{ dirty: #{item.myForm[k].$dirty} }\" data-edit=\"item.data.schedule.#{k}\">#{v}</span> #{thing} #{when_value} #{k}" if v > 0
        else
          schedule.push "#{v} #{thing} #{when_value} #{k}" if v > 0

      if html
        s = if item.data.dosage then "<span ng-class=\"{ dirty: #{item.myForm.dosage.$dirty} }\" data-edit=\"item.data.dosage\">#{item.data.dosage}</span>" else "___"
      else
        s = if item.data.dosage then "#{item.data.dosage}" else "___"
      s += " #{unit}"
      s += if schedule.length > 0 then ", #{action} #{schedule.join(', ')}" else ", #{action} ___"
      s

    options: options
