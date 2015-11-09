//create by BienlV
//08-08-2014 
//control view product type page
'use strict';
web365app.controller('resources', ['$scope', '$http', '$controller', '$timeout', 'resourcesServices', 'utilityServices',
    function ($scope, $http, $controller, $timeout, resourcesServices, utilityServices) {

      //extend baseController
      $.extend(this, $controller('baseController', { $scope: $scope }));      

      $scope.service = resourcesServices;

      $scope.submit = function (form) {

          $scope.dataForm = $(form.target).serialize();

          resourcesServices.saveResouces($scope.dataForm).then(function (res) {
              utilityServices.notificationSuccess('Lưu thành công', 'Đã lưu thông tin thuộc tính thành công');
          });
      };

      resourcesServices.getAllResouces('').then(function (res) {

          $scope.listResouces = res.list;

      });

  }]);