app.factory('ProductService', function($http, AuthService) {
  const API_URL = "http://localhost:3000/api/v1";

  function getAuthConfig(params) {
    const token = AuthService.getToken();
    return {
      headers: { Authorization: "Bearer " + token },
      params: params || {}
    };
  }

  return {
    getAll: function(category_id, params) {
      return $http.get(API_URL + `/catalog/categories/${category_id}/products`, getAuthConfig(params));
    },
    getMetadata: function(category_id, params) {
      return $http.get(API_URL + `/catalog/categories/${category_id}/metadata`, getAuthConfig(params));
    },
    get: function(id , category_id , sub_category_id) {
      return $http.get(API_URL + `/catalog/categories/${category_id}/sub_categories/${sub_category_id}/products/${id}`, getAuthConfig());
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