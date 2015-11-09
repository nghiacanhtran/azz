//create by BienLV2
//15-07-2014
//services use to other services
'use strict';
web365app.factory('resourcesServices', ['$q', '$templateCache', '$http', function ($q, $templateCache, $http) {

    var resourcesServices = {};

    var _getAllResouces = function (source) {

        var deferred = $q.defer();

        $http.get('/admin/Resources/GetAllResources', {
            params: {
                source: source
            }
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err, status) {
            deferred.reject(err);
        });

        return deferred.promise;

    };

    var _saveResouces = function (obj) {

        var deferred = $q.defer();

        $http.post('/admin/Resources/SaveResources', obj, {
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err, status) {
            deferred.reject(err);
        });

        return deferred.promise;

    };

    resourcesServices.getAllResouces = _getAllResouces;
    resourcesServices.saveResouces = _saveResouces;

    return resourcesServices;
}]);