app.factory('SubCategoryService', function ($http, AuthService) {
  var API_URL = 'http://localhost:3000/api/v1';

  function getAuthConfig() {
    var token = AuthService.getToken();
    return {
      headers: { Authorization: 'Bearer ' + token }
    };
  }

  return {
    getByCategory: function (category_id) {
      return $http.get(API_URL + '/catalog/categories/' + category_id + '/sub_categories', getAuthConfig());
    }
  };
});
