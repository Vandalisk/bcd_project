'use strict'

angular.module 'bcd'
  .filter 'nl2br', ($sce) ->
    (input, trust) ->
      input ||= ''
      trust ||= false
      if trust
        $sce.trustAsHtml(input.replace(/\n/g, '<br/>'))
      else
        input.replace /\n/g, '<br/>'


  .filter 'unsafe', ($sce) ->
    (val) ->
      $sce.trustAsHtml val

  .filter 'capitalize', ->
    (input) ->
      if (!!input) then input.charAt(0).toUpperCase() + input.substr(1).toLowerCase() else ''

  .filter 'impactConverter', ->
    impactTypes =
      'high_a1c': 'High A1c'
      'cholesterol/apob': 'Cholesterol/apoB'
      'high_blood_pressure': 'High Blood Pressure'
      'other': 'Other'
    (impact) ->
      impactTypes[impact]

  .filter 'treatmentTypeConverter', ($filter) ->
    (treatmentType) ->
      $filter('capitalize') (
        if /medication/i.exec(treatmentType)
          if treatmentType == 'medication_tablets'
            'Tablets'
          else
            'Injection'
        else
          treatmentType
      )
  .filter 'insuranceConverter', ($filter) ->
    insuranceTypes =
      'yes': 'Covered by BC Pharmacare, once deductible threshold reached'
      'yes_with_authority': 'Covered by BC Pharmacare (if eligible) with completion of Special Authority'
      'partial': 'Partial BC Pharmacare coverage'
      'no': 'Not covered by BC Pharmacare'
    (insurance) ->
      insuranceTypes[insurance]


