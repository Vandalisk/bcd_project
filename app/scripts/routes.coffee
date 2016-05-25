'use strict'

angular.module 'bcd'
  .config ($stateProvider, Acl) ->

    # home route
    $stateProvider
      .state 'home',
        url: '/'
        templateUrl: '/app/templates/common/index.html'
        data:
          access: Acl.access.public

    # doctor routes
    $stateProvider
      .state 'doctor',
        abstract: true
        templateUrl: '/app/templates/common/index.html'
        data:
          access: Acl.access.doctor

      .state 'doctor.accounts',
        abstract: true
        parent: 'doctor'
        templateUrl: '/app/templates/doctor/accounts/main.html'
        controller: 'ctrl.doctor.accounts'
        resolve:
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'accounts'
          pageCaption: -> 'Patients'
          user: (Users, ActivePatient, $stateParams) ->
            if ActivePatient.get()
              Users.item(ActivePatient.get())
              .then (res) ->
                $stateParams.userId = res.data.item.id
                res.data.item
            else
              false

      .state 'doctor.accounts.patients',
        url: '/patients'
        parent: 'doctor.accounts'
        templateUrl: '/app/templates/doctor/accounts/patients.html'
        controller: 'ctrl.doctor.accounts.patients'
        resolve:
          pageCaption: -> 'Patients'

      .state 'doctor.accounts.staff',
        url: '/staff'
        parent: 'doctor.accounts'
        templateUrl: '/app/templates/doctor/accounts/staff.html'
        controller: 'ctrl.doctor.accounts.staff'
        resolve:
          pageCaption: -> 'Staff'



      .state 'doctor.cqi_treatment_templates',
        abstract: true

      .state 'doctor.cqi_treatment_templates.list',
        url: '/cqi_treatment_templates',
        parent: 'doctor'
        templateUrl: '/app/templates/doctor/cqi_treatment_templates/list.html'
        controller: 'ctrl.doctor.CqiTreatmentTemplatesList'
        resolve:
          treatmentTemplates: (TreatmentTemplates) ->
            TreatmentTemplates.list
              per_page: 1000
            .then (res) -> res.data.collection
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'cqi_treatment_templates'
          pageCaption: -> 'Treatments List'
          user: (Users, ActivePatient, $stateParams) ->
            if ActivePatient.get()
              Users.item(ActivePatient.get())
              .then (res) ->
                $stateParams.userId = res.data.item.id
                res.data.item

      #TODO checkME
      .state 'doctor.cqi_treatment_templates.edit',
        url: '/cqi_treatment_templates/{treatmentTemplateId:[0-9]+}',
        parent: 'doctor'
        templateUrl: '/app/templates/doctor/cqi_treatment_templates/edit.html'
        controller: 'ctrl.doctor.CqiTreatmentTemplatesEdit'
        resolve:
          item: (TreatmentTemplates, $stateParams) ->
            TreatmentTemplates.item $stateParams.treatmentTemplateId
            .then (res) -> res.data.item
          sidebar: -> 'doctor'
          sidebarActiveItem: -> 'cqi_treatment_templates'
          pageCaption: -> 'Edit Treatment'

      .state 'doctor.add_user',
        url: '/add_user'
        parent: 'doctor'
        templateUrl: '/app/templates/doctor/add_user.html'
        controller: 'ctrl.doctor.AddUser'
        resolve:
          sidebar: -> 'doctor'
          sidebarActiveItem: -> 'add_user'
          pageCaption: -> 'Create User'

      .state 'doctor.doctors',
        abstract: true

      .state 'doctor.doctors.item',
        abstract: true
        url: '/d{userId:[0-9]+}'
        parent: 'doctor'
        template: '<div class="wrap" flex layout="row" ui-view></div>'
        resolve:
          user: (Users, $stateParams) ->
            Users.item($stateParams.userId)
            .then (res) -> res.data.item

      .state 'doctor.doctors.item.dashboard',
        url: '/'
        parent: 'doctor.doctors.item'
        templateUrl: '/app/templates/doctor/doctors_dashboard.html'
        controller: 'ctrl.doctor.DoctorsDashboard'
        resolve:
          sidebar: -> 'doctor.doctors.item'
          sidebarActiveItem: -> 'dashboard'
          pageCaption: -> 'Dashboard'

      .state 'doctor.doctors.item.edit',
        url: '/edit'
        parent: 'doctor.doctors.item'
        templateUrl: '/app/templates/doctor/edit_user.html'
        controller: 'ctrl.doctor.EditUser'
        resolve:
          user: (Users, $stateParams) ->
            Users.item($stateParams.userId)
            .then (res) -> res.data.item
          sidebar: -> 'doctor.doctors.item'
          sidebarActiveItem: -> 'profile'
          pageCaption: -> 'Edit User'

      .state 'doctor.patients',
        abstract: true

      .state 'doctor.patients.item',
        abstract: true
        url: '/p{userId:[0-9]+}'
        parent: 'doctor'
        template: '<div class="wrap" flex layout="row" ui-view></div>'
        resolve:
          user: (Users, $stateParams) ->
            Users.item($stateParams.userId)
            .then (res) -> res.data.item

      .state 'doctor.patients.item.dashboard',
        url: '/'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/doctor/patients_dashboard.html'
        controller: 'ctrl.doctor.PatientsDashboard'
        resolve:
          treatments: (Treatments, $stateParams) ->
            Treatments.list
              receiver_id: $stateParams.userId
              per_page: 1000
            .then (res) -> res.data.collection
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'dashboard'
          pageCaption: -> 'Dashboard'

      .state 'doctor.patients.item.edit',
        url: '/edit'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/doctor/edit_user.html'
        controller: 'ctrl.doctor.EditUser'
        resolve:
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'profile'
          pageCaption: -> 'Edit User'

      .state 'doctor.patients.item.cqi_treatments',
        abstract: true
        parent: 'doctor.patients.item'

      .state 'doctor.patients.item.cqi_treatments.list',
        url: '/cqi_treatments?new'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/common/cqi_treatments.html'
        controller: 'ctrl.common.CqiTreatmentsList'
        resolve:
          treatments: (Treatments, $stateParams) ->
            Treatments.list
              receiver_id: $stateParams.userId
              per_page: 1000
            .then (res) -> res.data.collection
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'cqi_treatments'
          pageCaption: -> 'Treatments List'

      .state 'doctor.patients.item.cqi_treatments.edit',
        url: '/cqi_treatments/{treatmentId:[0-9]+}'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/doctor/cqi_treatments/edit.html'
        controller: 'ctrl.doctor.CqiTreatmentsEdit'
        resolve:
          treatment: (Treatments, $stateParams) ->
            Treatments.item $stateParams.treatmentId
            .then (res) -> res.data.item
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'cqi_treatments'
          pageCaption: -> 'Edit Treatment'

      .state 'doctor.patients.item.cqi_health_program',
        url: '/cqi_treatments/new'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/common/cqi_health_program.html'
        controller: 'ctrl.doctor.CqiHealthProgram'
        resolve:
          treatmentTemplates: (TreatmentTemplates, ActivePatient) ->
            TreatmentTemplates.list
              per_page: 1000
              order: 'full_name'
              patient_id: ActivePatient.get()
            .then (res) -> res.data.collection
          sidebar: -> 'doctor.suggest_treatment'
          sidebarActiveItem: -> 'cqi_treatments'
          header: -> 'doctor.suggest_treatment'
          pageCaption: -> 'Treatments List'

      .state 'doctor.patients.item.cqi_tasks',
        abstract: true
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/doctor/cqi_tasks.html'
        controller: 'ctrl.common.CqiTasks'
        resolve:
          tasksData: (Tasks, $stateParams) ->
            Tasks.list
              date: moment().format('YYYY-MM-DD')
              treatment_receiver_id: $stateParams.userId
              treatment_status: 'active,completed'
            .then (res) ->
              tasks: res.data.tasks
              treatments: res.data.treatments
          newTreatmentsCount: (Treatments, $stateParams) ->
            Treatments.list
              receiver_id: $stateParams.userId
              per_page: 1000
              status: 'new'
            .then (res) -> res.data.collection.length
          sidebar: -> 'doctor.patients.item'
          tasksStatistic: (Users, user) ->
            Users.get_user_tasks(user.id)
            .then (res) ->
              res.data.tasks
          scores: (Users, user) ->
            Users.get_total_scores(user.id)
            .then (res) ->
              res.data.scores
          sidebarActiveItem: -> 'cqi_tasks'
          pageCaption: -> 'CQI Tasks'

      .state 'doctor.patients.item.cqi_tasks.list',
        url: '/cqi_tasks'

      .state 'doctor.patients.item.cqi_tasks.item',
        url: '/cqi_tasks/{taskId:[0-9]+}'

      .state 'doctor.patients.item.blood_glucose',
        url: '/blood_glucose'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/common/blood_glucose.html'
        controller: 'ctrl.common.bloodGlucose'
        resolve:
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'blood_glucose'
          pageCaption: -> 'Blood Glucose'

      .state 'doctor.patients.item.lab_results',
        url: '/lab_results'
        parent: 'doctor.patients.item'
        templateUrl: '/app/templates/common/lab_results.html'
        controller: 'ctrl.common.LabResults'
        resolve:
          sidebar: -> 'doctor.patients.item'
          sidebarActiveItem: -> 'lab_results'
          pageCaption: -> 'Lab Results'


    # patient routes
    $stateProvider
      .state 'patient',
        abstract: true
        templateUrl: '/app/templates/common/index.html'
        data:
          access: Acl.access.patient

      .state 'patient.home',
        url: '/'
        parent: 'patient'
        templateUrl: '/app/templates/patient/home.html'
        controller: 'ctrl.patient.Home'
        resolve:
          newTreatmentsCount: (Treatments, $rootScope) ->
            Treatments.list
              receiver_id: $rootScope.currentUser.id
              per_page: 1000
              status: 'new'
            .then (res) -> res.data.collection.length
          sidebar: -> 'patient'
          sidebarActiveItem: -> ''
          pageCaption: -> 'CQI'

      .state 'patient.cqi_treatments',
        url: '/cqi_treatments'
        parent: 'patient'
        templateUrl: '/app/templates/common/cqi_treatments.html'
        controller: 'ctrl.common.CqiTreatmentsList'
        resolve:
          user: ($rootScope) ->
            $rootScope.currentUser
          treatments: (Treatments, $rootScope) ->
            Treatments.list
              receiver_id: $rootScope.currentUser.id
              per_page: 1000
            .then (res) -> res.data.collection
          sidebar: -> 'patient'
          sidebarActiveItem: -> 'cqi_treatments'
          pageCaption: -> 'Treatments List'

      .state 'patient.education_materials',
        url: '/education_materials'
        parent: 'patient'
        templateUrl: '/app/templates/patient/education_materials.html'
        controller: 'ctrl.patient.EducationMaterials'
        resolve:
          user: ($rootScope) ->
            $rootScope.currentUser
          sidebar: -> 'patient'
          sidebarActiveItem: -> 'education_materials'
          pageCaption: -> 'Education materials'

      .state 'patient.cqi_tasks',
        abstract: true
        parent: 'patient'
        templateUrl: '/app/templates/patient/cqi_tasks.html'
        controller: 'ctrl.common.CqiTasks'
        resolve:
          user: ($rootScope) ->
            $rootScope.currentUser
          tasksData: (Tasks, $rootScope) ->
            Tasks.list
              date: moment().format('YYYY-MM-DD')
              treatment_receiver_id: $rootScope.currentUser.id
              treatment_status: 'active,completed'
            .then (res) ->
              tasks: res.data.tasks
              treatments: res.data.treatments
          newTreatmentsCount: (Treatments, $rootScope) ->
            Treatments.list
              receiver_id: $rootScope.currentUser.id
              per_page: 1000
              status: 'new'
            .then (res) -> res.data.collection.length
          sidebar: -> 'patient'
          sidebarActiveItem: -> 'cqi_tasks'
          pageCaption: -> 'Daily Tasks'
          scores: (Users, user) ->
            Users.get_total_scores(user.id)
            .then (res) ->
              res.data.scores
          tasksStatistic: (Users, user) ->
            Users.get_user_tasks(user.id)
            .then (res) ->
              res.data.tasks


      .state 'patient.cqi_tasks.list',
        url: '/cqi_tasks'

      .state 'patient.cqi_tasks.item',
        url: '/cqi_tasks/{taskId:[0-9]+}'


      .state 'patient.cqi_health_program',
        abstract: true
        parent: 'patient'
        templateUrl: '/app/templates/common/cqi_health_program.html'
        controller: 'ctrl.patient.CqiHealthProgram'
        resolve:
          user: ($rootScope) ->
            $rootScope.currentUser
          treatmentTemplates: (TreatmentTemplates) ->
            TreatmentTemplates.list
              per_page: 1000
              order: 'full_name'
            .then (res) -> res.data.collection
          sidebar: -> 'patient'
          sidebarActiveItem: -> 'cqi_treatments'
          pageCaption: -> 'Treatments List'

      .state 'patient.cqi_health_program.list',
        url: '/hp'

      .state 'patient.cqi_health_program.item',
        url: '/hp/{treatmentTemplateId:[0-9]+}'

      .state 'patient.cqi_health_program.selected',
        url: '/hp/selected'

      .state 'patient.blood_glucose',
        url: '/blood_glucose'
        parent: 'patient'
        templateUrl: '/app/templates/common/blood_glucose.html'
        controller: 'ctrl.common.bloodGlucose'
        resolve:
          user: ($rootScope) -> $rootScope.currentUser
          sidebar: -> 'patient'
          sidebarActiveItem: -> 'blood_glucose'
          pageCaption: -> 'Blood Glucose'

      .state 'patient.lab_results',
        url: '/lab_results'
        parent: 'patient'
        templateUrl: '/app/templates/common/lab_results.html'
        controller: 'ctrl.common.LabResults'
        resolve:
          user: ($rootScope) -> $rootScope.currentUser
          sidebar: -> 'patient'
          sidebarActiveItem: -> 'lab_results'
          pageCaption: -> 'Lab Results'


    # common routes
    $stateProvider
      .state 'public',
        abstract: true
        templateUrl: '/app/templates/common/index.html'
        data:
          access: Acl.access.public
          body_css: 'light'

      .state 'forgot_password',
        url: '/forgot_password'
        parent: 'public'
        templateUrl: '/app/templates/common/forgot_password.html'
        controller: 'ctrl.common.ForgotPassword'
        resolve:
          pageCaption: -> 'Forgot Password'

      .state 'invite',
        url: '/invite/{token:[a-z0-9]+}'
        parent: 'public'
        templateUrl: '/app/templates/common/join_invitation.html'
        controller: 'ctrl.common.SetPassword'
        resolve:
          user: (Auth, $stateParams) ->
            Auth.findByToken
              token_type: 'invite'
              token: $stateParams.token
            .then (res) -> res.data.item
          token_type: -> 'invite'
          pageCaption: -> 'Invitation'

      .state 'reset_password',
        url: '/reset_password/{token:[a-z0-9]+}'
        parent: 'public'
        templateUrl: '/app/templates/common/set_password.html'
        controller: 'ctrl.common.SetPassword'
        resolve:
          user: (Auth, $stateParams) ->
            Auth.findByToken
              token_type: 'reset_password'
              token: $stateParams.token
            .then (res) -> res.data.item
          token_type: -> 'reset_password'
          pageCaption: -> 'Reset Password'

      .state 'profile',
        url: '/profile'
        parent: 'public'
        templateUrl: '/app/templates/common/profile.html'
        controller: 'ctrl.common.Profile'
        data:
          body_css: ''
        resolve:
          user: (Profile) ->
            Profile.profile()
            .then (res) -> res.data.item
          pageCaption: -> 'My Profile'


      .state 'dialogs',
        abstract: true
        parent: 'public'
        templateUrl: '/app/templates/common/dialogs.html'
        controller: 'ctrl.common.Dialogs'
        data:
          body_css: ''
        resolve:
          dialogs_messages: ($rootScope, Dialogs) ->
            Dialogs.list
              per_page: 1000
            .then (res) -> res.data
          sidebar: ($rootScope) ->
            if $rootScope.currentUser.role is 'admin' or $rootScope.currentUser.role is 'doctor'
              'doctor.patients.item'
            else
              'patient'
          sidebarActiveItem: -> 'dialogs'
          pageCaption: -> 'Messages'
          user: (Users, ActivePatient, $stateParams, $rootScope) ->
            if $rootScope.currentUser.role is 'admin' or $rootScope.currentUser.role is 'doctor'
              if ActivePatient.get()
                Users.item(ActivePatient.get())
                .then (res) ->
                  $stateParams.userId = res.data.item.id
                  res.data.item
            else
              $rootScope.currentUser


      .state 'dialogs.list',
        url: '/im'

      .state 'dialogs.item',
        url: '/im/{receiverId:[0-9]+}'


      .state '404',
        url: '*path'
        parent: 'public'
        templateUrl: '/app/templates/common/404.html'
