'use strict'

angular.module 'bcd'
  .filter 'completedFilter', () ->
    (items) ->
      _.where(items, { is_completed: true })
