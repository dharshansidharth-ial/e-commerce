app.service("SellerService", function($http) {
  const API_URL = "http://localhost:3000/api/v1/";

  this.getDashboard = function() {
    return $http.get(API_URL + "seller/dashboard");
  };

  this.getProducts = function() {
    return $http.get(API_URL + "seller/products");
  };

  this.createProduct = function(product) {
    return $http.post(API_URL + "seller/products", { product: product });
  };

  this.updateProduct = function(product) {
    return $http.patch(API_URL + "seller/products/" + product.id, { product: product });
  };

  this.deleteProduct = function(productId) {
    return $http.delete(API_URL + "seller/products/" + productId);
  };
});
