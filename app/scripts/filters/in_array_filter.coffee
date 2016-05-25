'use strict'

angular.module 'bcd'
  .filter 'inArray', ($filter) ->
    (list, arrayFilter, element) ->
      if arrayFilter && list.length > 0
        if element
          $filter('filter') list, (listItem) ->
            arrayFilter.indexOf(listItem[element]) isnt -1
        else
          $filter('filter') list, (listItem) ->
            arrayFilter.indexOf(listItem) isnt -1
