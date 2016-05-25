'use strict'

angular.module 'bcd'
  .factory 'TreatmentLifestyleDecorator', ->
    options:
      masterSteps: ['name', 'type', 'schedule', 'description']
      captionNextStep: 'Proceed to treatment description'
    conditionText: (item) ->
      if item.data.condition then item.data.condition else ''
