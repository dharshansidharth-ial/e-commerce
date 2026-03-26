app.service("AdminService", function($http) {
  const API_URL = "http://localhost:3000/api/v1/";

  this.getCurrentUser = function() {
    return $http.get(API_URL + "users/me");
  };

  this.getProducts = function() {
    return $http.get(API_URL + "admin/products");
  };

  this.createProduct = function(product) {
    return $http.post(API_URL + "admin/products", { product: product });
  };

  this.updateProduct = function(product) {
    return $http.patch(API_URL + "admin/products/" + product.id, { product: product });
  };

  this.deleteProduct = function(productId) {
    return $http.delete(API_URL + "admin/products/" + productId);
  };

  this.getOrders = function() {
    return $http.get(API_URL + "admin/orders");
  };

  this.updateOrderStatus = function(orderId, status) {
    return $http.patch(API_URL + "admin/orders/" + orderId, {
      order: { status: status }
    });
  };

  this.getReviews = function() {
    return $http.get(API_URL + "admin/reviews");
  };

  this.deleteReview = function(reviewId) {
    return $http.delete(API_URL + "admin/reviews/" + reviewId);
  };

  this.getCategories = function() {
    return $http.get(API_URL + "catalog/categories");
  };

  this.getSellers = function() {
    return $http.get(API_URL + "admin/users");
  };

  this.updateSellerStatus = function(sellerId, sellerStatus) {
    return $http.patch(API_URL + "admin/users/" + sellerId, {
      user: { seller_status: sellerStatus }
    });
  };

  this.createCategory = function(data){
    return $http.post(API_URL + "catalog/categories" , data)
  }

  this.deleteCategory = function(cid){
    return $http.delete(API_URL + `catalog/categories/${cid}`)
  }
});
