//create by BienlV
//08-08-2014 
//control view product type page
'use strict';
web365app.controller('video', ['$scope', '$http', '$controller', '$timeout', 'videoService',
  function ($scope, $http, $controller, $timeout, videoService) {

      //extend baseController
      $.extend(this, $controller('baseController', { $scope: $scope }));      

      $scope.service = videoService;

      $scope.formViewTemplate = '/Angular/Views/Admin/video/detail.html';

      $scope.dataFilter = {
          name: '',
          currentRecord: 0,
          numberRecord: $scope.listNumberRow[0],
          currentPage: 1,
          propertyNameSort: 'ID',
          descending: true
      };            

      $scope.loadDataForm = function (data) {
          videoService.getEditForm(data).then(function (res) {

              $scope.data = res.data;

              $scope.listTreeDataForm = res.listType;

              $scope.openModal('/Angular/Views/Admin/video/edit.html');

          });
      };      

      $scope.loadData();

      $scope.loadDataTree();

  }]);

'use strict';
web365app.controller('videoModified', ['$scope', '$http', '$controller', 'videoService',
  function ($scope, $http, $controller, videoService) {

      //extend baseController
      //$.extend(this, $controller('baseController', { $scope: $scope }));

      $scope.submit = function (form) {

          $scope.dataForm = $(form.target).serialize();

          videoService.modified($scope.dataForm).then(function (res) {

              $scope.resetList();

              $scope.cancel();

          });
      };

  }]);