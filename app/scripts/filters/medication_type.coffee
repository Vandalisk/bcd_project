'use strict'

angular.module 'bcd'
.filter 'medicationType', () ->
  (items, type) ->
    action = if type == 'medicationTabs' then 'take' else 'inject'
    _.filter(items, action: action)
