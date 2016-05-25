'use strict'

angular.module 'bcd'
  .factory 'Profile', ($http) ->
    profile: (success) ->
      $http.get "#{appConfig.urlApi}/auth/profile"
    profileSubmit: (data, success, error) ->
      $http.put "#{appConfig.urlApi}/auth/profile", data


  .factory 'Users', ($http) ->
    list: (params) ->
      $http.get "#{appConfig.urlApi}/users", params: params
    item: (id) ->
      $http.get "#{appConfig.urlApi}/users/#{id}"
    create: (data) ->
      $http.post "#{appConfig.urlApi}/users", data
    update: (id, data) ->
      $http.put "#{appConfig.urlApi}/users/#{id}", data
    get_total_scores: (id) ->
      $http.get "#{appConfig.urlApi}/users/#{id}/get_total_scores"
    get_user_tasks: (id) ->
      $http.get "#{appConfig.urlApi}/users/#{id}/calculate_completed_tasks"
    check_phn: (id, phn) ->
      $http.get "#{appConfig.urlApi}/users/#{id}/check_phn", params: phn

  .factory 'TreatmentTemplates', ($http, $q, TreatmentTemplateTotalScoreCalculator) ->
    list: (params) ->
      deferred = $q.defer()

      $http.get("#{appConfig.urlApi}/treatment_templates", params: params)
      .success (response) =>
        res =
          data:
            collection: response.collection.map (item) =>
              item.isCollapsed = true
              item.calculatedPoints = TreatmentTemplateTotalScoreCalculator.calculate(item)
              if item.treatment_type == 'medication_tablets' || item.treatment_type == 'medication_injection'
                _.each item.data.schedule, (v, k) ->
                  item.data.schedule[k] = parseFloat(v)
              item
        deferred.resolve(res)
      .error (response) =>
        deferred.reject(response)

      deferred.promise
    item: (id) ->
      $http.get "#{appConfig.urlApi}/treatment_templates/#{id}"
    create: (data) ->
      $http.post "#{appConfig.urlApi}/treatment_templates", data
    update: (id, data) ->
      $http.put "#{appConfig.urlApi}/treatment_templates/#{id}", data
    destroy: (id) ->
      $http.delete "#{appConfig.urlApi}/treatment_templates/#{id}"
    uniq: (params) ->
      $http.get "#{appConfig.urlApi}/treatment_templates/uniq", params: params
    checkByName: (params) ->
      $http.get "#{appConfig.urlApi}/treatment_templates/check_by_name", params: params



  .factory 'Treatments', ($http, $q) ->
    list: (params) ->
      deferred = $q.defer()

      $http.get("#{appConfig.urlApi}/treatments.json", params: params)
      .success (response) =>
        res =
          data:
            collection: response.collection.map (item) =>
              item.model = new Treatment(item)
              if item.treatment_type == 'medication_tablets' || item.treatment_type == 'medication_injection'
                _.each item.data.schedule, (v, k) ->
                  item.data.schedule[k] = parseFloat(v)
              item
        deferred.resolve(res)
      .error (response) =>
        deferred.reject(response)

      deferred.promise

    item: (id) ->
      $http.get "#{appConfig.urlApi}/treatments/#{id}"
    create: (data) ->
      $http.post "#{appConfig.urlApi}/treatments", data
    update: (id, data) ->
      $http.put "#{appConfig.urlApi}/treatments/#{id}", data
    update_current: (id, data) ->
      $http.put "#{appConfig.urlApi}/treatments/#{id}/update_current", data
    destroy: (id) ->
      $http.delete "#{appConfig.urlApi}/treatments/#{id}"
    submit_treatments: (data) ->
      $http.post "#{appConfig.urlApi}/treatments/submit_treatments", data
    prescribe_requested_treatment: (id, data) ->
      $http.put "#{appConfig.urlApi}/treatments/#{id}/prescribe_requested_treatment", data
    uniq: (params) ->
      $http.get "#{appConfig.urlApi}/treatments/uniq", params: params


  .factory 'BloodGlucoses', ($http) ->
    list: (params) ->
      $http.get "#{appConfig.urlApi}/blood_glucoses", params: params
    create: (data) ->
      $http.post "#{appConfig.urlApi}/blood_glucoses", data
    update: (id, data) ->
      $http.put "#{appConfig.urlApi}/blood_glucoses/#{id}", data
    destroy: (id) ->
      $http.delete "#{appConfig.urlApi}/blood_glucoses/#{id}"

  .factory 'Tasks', ($http) ->
    list: (params) ->
      $http.get "#{appConfig.urlApi}/tasks", params: params
    item: (id) ->
      $http.get "#{appConfig.urlApi}/tasks/#{id}"
    update: (id, data) ->
      $http.put "#{appConfig.urlApi}/tasks/#{id}", data
    updateAll: (data) ->
      $http.put "#{appConfig.urlApi}/tasks/update_all", data


  .factory 'Dialogs', ($http) ->
    list: (params) ->
      $http.get "#{appConfig.urlApi}/dialogs", params: params
    dialogs_unread_count: ->
      $http.get "#{appConfig.urlApi}/dialogs/dialogs_unread_count"


  .factory 'Messages', ($http) ->
    list: (params) ->
      $http.get "#{appConfig.urlApi}/messages", params: params
    item: (id) ->
      $http.get "#{appConfig.urlApi}/messages/#{id}"
    create: (data) ->
      $http.post "#{appConfig.urlApi}/messages", data
    update: (id, data) ->
      $http.put "#{appConfig.urlApi}/messages/#{id}", data
    readMultiple: (data) ->
      $http.put "#{appConfig.urlApi}/messages/read_multiple", data

  .factory 'LabResults', ($http) ->
    list: (params) ->
      $http.get "#{appConfig.urlApi}/lab_results/from_dpd", params: params
