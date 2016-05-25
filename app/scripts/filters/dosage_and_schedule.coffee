'use strict'

angular.module 'bcd'
  .filter 'dosageAndSchedule', (TreatmentDecorator) ->
    (input) ->
      TreatmentDecorator.dosageAndSchedule(input)
