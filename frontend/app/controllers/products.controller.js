app.controller(
  "ProductsController",
  function ($scope, ProductService, CartService, AuthService, $location) {
    $scope.products = [];
    $scope.error = null;
    $scope.isCustomer = AuthService.isCustomer();

    const token = AuthService.getToken();
    if (!token) {
      $location.path("/login");
      return;
    }

    // Load all products
    ProductService.getAll()
      .then(function (response) {
        $scope.products = response.data;
      })
      .catch(function (error) {
        $scope.error = error.data?.error || "Failed to load products";
      });

    // Add to cart
    $scope.addToCart = function (product , quantity) {
      if (!AuthService.isCustomer()) {
        alert("Only customers can buy products.");
        return;
      }

      console.log("in addToCart" , quantity)
      if (!product || !product.id) {
        console.error("Invalid product", product);
        return;
      }

      CartService.addItem(product.id, 1)
        .then(function () {
          alert("Product added to cart 🛒");
        })
        .catch(function (err) {
          console.log(err)
          alert(err.data.error)
        })
    };

    // Redirect to product page
    $scope.productView = function (product) {
      // if (!product || !product.id) {
      //   console.log("Invalid Product!", product);
      //   return;
      // }  
      $scope.product = product

      $location.path("/products/" + product.id);
    };
  },
);
