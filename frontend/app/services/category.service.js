app.factory('CategoryService', function ($http, AuthService) {
  var API_URL = 'http://localhost:3000/api/v1';

  function getAuthConfig() {
    var token = AuthService.getToken();
    return {
      headers: { Authorization: 'Bearer ' + token }
    };
  }

  return {
    getAll: function () {
      return $http.get(API_URL + '/catalog/categories', getAuthConfig());
    }
  };
});
