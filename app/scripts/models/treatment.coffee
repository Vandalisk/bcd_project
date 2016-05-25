class Treatment
  constructor: (treatment) ->
    @id = treatment.id
    @senderId = treatment.sender_id
    @doctorFullName = treatment.doctor_full_name
    @patientFullName = treatment.patient_full_name
    @receiverId = treatment.receiver_id
    @treatmentTemplateId = treatment.treatment_template_id
    @treatmentType = treatment.treatment_type
    @name = treatment.name
    @data = treatment.data
    @frequency = treatment.frequency
    @period = treatment.period
    @startAt = moment(treatment.date_start)
    @endAt = moment(treatment.date_end)
    @description = treatment.description
    @status = treatment.status
    @completionPercent = treatment.completion_percent
    @fullName = treatment.full_name
    @createdAt = moment(treatment.created_at)
    @updatedAt = moment(treatment.updated_at)
    @suggestOrRequest = treatment.suggest_or_request
    @acceptedByFullName = treatment.accepted_by_full_name
    @declinedByFullName = treatment.declined_by_full_name
    @declinedAt = moment(treatment.declined_at) if treatment.declined_at?
    @complianceRate = treatment.compliance_rate
    @isCollapsed = true
    # TODO: use snakeCase for model attributes
    @reciever_gravatar_url = treatment.reciever_gravatar_url
    @sender_gravatar_url = treatment.sender_gravatar_url
    @doctorComment = treatment.doctor_comment
    @patientComment = treatment.patient_comment

  formattedCreatedAt: ->
    @createdAt.format("YYYY MMM D")

  formattedStartAt: ->
    @startAt.format("YYYY MMM D")

  formattedEndAt: ->
    @endAt.format("YYYY MMM D")

  formattedDeclinedAt: ->
    @declinedAt.format("YYYY MMM D") if @declinedAt?

  endsIn: ->
    @endAt.diff(moment(), 'days')

  suggestOrRequestBy: ->
    if @suggestOrRequest == 'suggest'
      "Suggested: #{@formattedCreatedAt()} by #{@doctorFullName}"
    else
      "Requested: #{@formattedCreatedAt()} by #{@patientFullName}"




window.Treatment = Treatment
