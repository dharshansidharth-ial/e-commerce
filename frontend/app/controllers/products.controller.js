app.controller(
  "ProductsController",
  function ($scope, ProductService, CartService, AuthService, $location, $routeParams) {
    $scope.products = [];
    $scope.error = null;
    $scope.loading = true;
    $scope.isCustomer = AuthService.isCustomer();

    const category_id = $routeParams.category_id;

    const token = AuthService.getToken();
    if (!token) {
      $location.path("/login");
      return;
    }

    // Load all products for this category
    ProductService.getAll(category_id)
      .then(function (response) {
        $scope.products = response.data;
      })
      .catch(function (error) {
        $scope.error = error.data?.error || "Failed to load products";
      })
      .finally(function () {
        $scope.loading = false;
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
