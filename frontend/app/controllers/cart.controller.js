app.controller("CartController", function ($scope, $location , CartService) {
  $scope.cartItems = [];
  $scope.error = null;

  function loadCart() {
    CartService.getCart()
      .then(function (response) {
        $scope.cartItems = (response.data.cart_items || []).map((item) => {
          if (item.product) {
            item.product.price = Number(item.product.price || 0);
          } else {
            // If product is missing, create a dummy object to avoid errors
            item.product = { name: "Unknown", price: 0 };
          }
          // console.log(response);
          return item;
        }).sort(function(a , b){
          return a.id - b.id
        })
        // console.log($scope.cartItems);
        $scope.total = response.data.total;
        // $scope.cartItems = [response.data.cart_items , response.data.total]
      })
      .catch(function (error) {
        console.error("Failed to load cart", error);
        $scope.error = "Failed to load cart";
      });

    $scope.updateQuantity = function (item) {
      if (item.quantity < 1) {
        item.quantity = 1;
      }

      CartService.updateQuantity(item)
        .then(function (res) {
          // console.log("cart updated!");
          $scope.error = null;
          loadCart()
        })
        .catch(function (err) {
          console.log("Update failed", err);

          if (err.data && err.data.error) {
            $scope.error = err.data.error;
          } else {
            $scope.error = "Out of stock!";
          }

          // reload correct quantity from server
          loadCart();
        });
    };

    $scope.removeItem = function(item_id){
      CartService.removeItem(item_id)
      .then(function(res){
        console.log("deleted successfully!")
        loadCart()
      })
      .catch(function(err){
        console.log("cannot remove!" , err)
        $scope.error = err
      })
    }

    $scope.proceedToCheckout = function(){
      console.log("in proceedToCheckout")
      $location.path("/checkout")
    }
  }

  loadCart();
});
