app.service("CartService", function($http, AuthService) {

  const API_URL = "http://localhost:3000/api/v1/";

  function authConfig() {
    const token = AuthService.getToken();

    return token
      ? {
          headers: {
            Authorization: "Bearer " + token
          }
        }
      : {};
  }

  this.addItem = function(productId, quantity) {
    // console.log("from addItem");
    

    console.log("CartService sending:", productId, quantity);

    return $http.post(
      API_URL + "shopping/cart/cart_items",
      {
        cart_item: {
          product_id: productId,
          quantity: quantity
        }
      },
      authConfig()
    );
  };

  this.getCart =function() {
    const res = ($http.get(API_URL + "shopping/cart", authConfig()))
    // console.log(res)
    return res
  }

  this.removeItem = function(item_id){
    return $http.delete(
      API_URL + "shopping/cart/cart_items/" + String(item_id),
      authConfig()
    )
  }
  
  this.updateQuantity = function(item) {
    return $http.patch(
      API_URL + "shopping/cart/cart_items/" + item.id,
      {
        cart_item: {
          quantity: item.quantity
        }
      },
      authConfig()
    );
  }

  

});
