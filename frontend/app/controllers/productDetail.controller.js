app.controller(
  "ProductDetailController",
  function (
    $scope,
    ProductService,
    CartService,
    AuthService,
    $location,
    $routeParams,
  ) {
    const token = AuthService.getToken();
    if (!token) {
      $location.path("/login");
      return;
    }

    const id = $routeParams.id;

    $scope.product = null;
    $scope.reviews = [];
    $scope.newReview = {};
    $scope.quantity = 1;
    $scope.isCustomer = AuthService.isCustomer();

    ProductService.get(id)
      .then(function (response) {
        $scope.product = response.data;
      })
      .catch(function () {
        $scope.error = "Failed to load product";
      });

    // Load reviews
    ProductService.getReviews(id)
      .then(function (response) {
        $scope.reviews = response.data;
        calculateAverageRating();
      })
      .catch(function () {
        // Reviews might not be implemented yet
      });

    function calculateAverageRating() {
      if ($scope.reviews.length === 0) {
        $scope.averageRating = 0;
        return;
      }
      const sum = $scope.reviews.reduce(
        (acc, review) => acc + review.rating,
        0,
      );
      $scope.averageRating = Math.round(sum / $scope.reviews.length);
    }

    $scope.addToCart = function (product, quantity) {
      if (!AuthService.isCustomer()) {
        $scope.error = "Only customers can buy products.";
        return;
      }

      console.log("in addToCart ProductDetailController");
      CartService.addItem(product.id, quantity)
        .then(function () {
          console.log("from catch")
          $scope.success = "Product added to cart!";
          alert("added to cart successfully!");
        })
        .catch(function (err) {
          if (err.data === "Insufficient stock!"){
            alert("Out of stock!")
          }
            $scope.error = "Failed to add to cart";
        });
    };

    $scope.submitReview = function () {
      if (!AuthService.isCustomer()) {
        $scope.error = "Only customers can post reviews.";
        return;
      }

      if (!$scope.newReview.rating || !$scope.newReview.comment) {
        $scope.error = "Please fill all fields";
        return;
      }
      ProductService.addReview({
        review: {
          rating: $scope.newReview.rating,
          comment: $scope.newReview.comment,
          product_id: id,
        },
      })
        .then(function (response) {
          $scope.reviews.push(response.data);
          calculateAverageRating();
          $scope.newReview = {};
          $scope.success = "Review submitted!";
        })
        .catch(function () {
          $scope.error = "Failed to submit review";
        });
    };
  },
);
