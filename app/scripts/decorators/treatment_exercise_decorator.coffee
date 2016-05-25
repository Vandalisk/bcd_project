'use strict'

angular.module 'bcd'
  .factory 'TreatmentExerciseDecorator', ->
    options:
      masterSteps: ['name', 'type', 'schedule', 'description']
      captionNextStep: 'Proceed to treatment description'
    conditionText: (item) ->
      if item.data.count && item.data.condition then " #{item.data.count} #{item.data.condition}" else ''
