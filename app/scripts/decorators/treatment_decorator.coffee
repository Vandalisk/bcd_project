'use strict'

angular.module 'bcd'
  .factory 'TreatmentDecorator', (TreatmentMedicationInjectionDecorator, TreatmentMedicationTabletsDecorator, TreatmentExerciseDecorator, TreatmentLifestyleDecorator, FrequencyOptions) ->
    decorator = (item) ->
      if item.treatment_type is 'medication_tablets'
        TreatmentMedicationTabletsDecorator
      else if item.treatment_type is 'medication_injection'
        TreatmentMedicationInjectionDecorator
      else if item.treatment_type is 'exercise'
        TreatmentExerciseDecorator
      else if item.treatment_type is 'lifestyle'
        TreatmentLifestyleDecorator
      else
        {}

    format = (item) ->
      item.model = new Treatment(item)
      if item.treatment_type == 'medication_tablets' || item.treatment_type == 'medication_injection'
        _.each item.data.schedule, (v, k) ->
          item.data.schedule[k] = parseFloat(v)
      item

    conditionText = (item, small, html) ->
      try decorator(item).conditionText(item, small, html)

    options = (item) ->
      FrequencyOptions.options(decorator(item), item)

    calculatedPoints = (item, month = false) ->
      try FrequencyOptions.calculatedPoints(item, month)

    fullName = (item, small = false, html = false) ->
      if _.isEmpty(item.name)
        ""
      else if _.isEmpty(item.data) && item.treatment_type != 'lifestyle'
        item.name
      else
        s = "#{item.name}: #{conditionText(item, small, html)}"
        unless small
          frequencyOptions = options(item).frequencyOptions
          frq = _.findWhere frequencyOptions, key: item.frequency
          frq = frq.name.toLowerCase() if frq

          if frq
            if html && item.myForm
              s += ", <span ng-class=\"{ dirty: #{item.myForm.frequency.$dirty} }\" </span> #{frq}" if item.myForm.frequency
            else
              s += ", #{frq}"

          if item.open_ended
            if html && item.myForm
              s += ", <span ng-class=\"{ dirty: #{item.myForm.open_ended.$dirty} }\" </span> open-ended" if item.myForm.open_ended
            else
              s += ", open-ended"
          else if item.period && item.period.toString().length > 0
            if html && item.myForm
              s += ", <span ng-class=\"{ dirty: #{item.myForm.period.$dirty} }\" </span> for #{item.period} days" if item.myForm.period
            else
              s += ", for #{item.period} days"
        s

    dosageAndSchedule = (item) ->
      conditionText(item, true, true)

    decorator: decorator
    conditionText: conditionText
    options: options
    fullName: fullName
    dosageAndSchedule: dosageAndSchedule
    calculatedPoints: calculatedPoints
    format: format
