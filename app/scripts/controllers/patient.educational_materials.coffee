'use strict'

angular.module 'bcd'
  .controller 'ctrl.patient.EducationMaterials', ($scope, sidebar, sidebarActiveItem) ->
    $scope.sidebar = sidebar
    $scope.sidebarActiveItem = sidebarActiveItem
    $scope.diabetLink = "http://www.bcdiabetes.ca/wp-content/Handouts/For%20patients/Diabetes/"
    $scope.thyroidLink = "http://www.bcdiabetes.ca/wp-content/Handouts/For%20patients/Thyroid/"

    $scope.diabets = [
      { link: "2%E5%9E%8B%E7%B3%96%E5%B0%BF%E7%97%85%E7%AE%80%E4%BB%8B_Type%202%20diabetes.pdf", name: "Type 2 Diabetes" },
      { link: "Adjustment%20of%20Apidra%20insulin%20v1%20%28spanish%29.pdf", name: "Adjustment of Apidra Insulin V1 (spanish)" },
      { link: "Adjustment%20of%20Lantus%20insulin%20v2%20%28spanish%29.pdf", name: "Adjustment of Lantus Insulin V2 (spanish)" },
      { link: "Carb%20counting.pdf", name: "Carb Counting" },
      { link: "Principles%20of%20Type%202%20Diabetes%20Management.pdf", name: "Principles of Type 2 Diabetes Management" },
      { link: "Type%201%20Diabetes.pdf", name: "Type 1 Diabetes" },
      { link: "Type%202%20Diabetes.pdf", name: "Type 2 Diabetes" },
      { link: "Type%202%20diabetes%20-%20punjabi.pdf", name: "Type 2 Diabetes Punjabi" }
    ]

    $scope.thyroids = [
      { link: "Hyperthyroidism%20%20%28Chinese%29.pdf", name: "Hyperthyroidism (Chinese)" },
      { link: "Hyperthyroidism_Graves%20disease.pdf", name: "Hyperthyroidism Graves Disease" },
      { link: "Hypothyroidism%20%28Chinese%29.pdf", name: "Hypothyroidism (Chinese)" },
      { link: "Hypothyroidism%20%28English%29.pdf", name: "Hypothyroidism (English)" }
    ]

