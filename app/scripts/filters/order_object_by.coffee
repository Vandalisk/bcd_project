'use strict'

angular.module 'bcd'
.filter 'orderObjectBy', ($filter) ->
  (items, field, reverse) ->
    filtered = [];
    angular.forEach items, (item, key) ->
      item.key = key
      filtered.push(item);
    filtered.sort (a, b) ->
      (a[field] > b[field] ? 1 : -1)
    filtered.reverse() if reverse
    filtered
