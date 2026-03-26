app.factory('ProductService', function($http, AuthService) {
  const API_URL = "http://localhost:3000/api/v1";

  function getAuthConfig() {
    const token = AuthService.getToken();
    return {
      headers: { Authorization: "Bearer " + token }
    };
  }

  return {
    getAll: function() {
      return $http.get(API_URL + '/catalog/products', getAuthConfig());
    },
    get: function(id) {
      return $http.get(API_URL + '/catalog/products/' + id, getAuthConfig());
    },
    productView: function(id){
      return $http.get(API_URL + '/catalog/products/' + id , getAuthConfig())
    },
    getReviews: function(id) {
      return $http.get(API_URL + '/feedback/reviews?product_id=' + id, getAuthConfig());
    },
    addReview: function(review) {
      return $http.post(API_URL + '/feedback/reviews', review, getAuthConfig());
    }
  };
});