app.controller(
  "ProductsController",
  function ($scope, ProductService, SubCategoryService, CartService, AuthService, $location, $routeParams) {
    $scope.allProducts = [];
    $scope.products = [];
    $scope.subCategories = [];
    $scope.subCategoryCounts = {};
    $scope.selectedSubCategoryIds = {};
    $scope.error = null;
    $scope.loading = true;
    $scope.isCustomer = AuthService.isCustomer();

    // Pagination is UI-only for now: it just tracks/highlights the
    // current page, it doesn't slice which products are rendered.
    var PAGE_SIZE = 8;
    $scope.currentPage = 1;
    $scope.totalPages = 1;
    $scope.pageNumbers = [1];

    const category_id = $routeParams.category_id;

    const token = AuthService.getToken();
    if (!token) {
      $location.path("/login");
      return;
    }

    function computeSubCategoryCounts() {
      var counts = {};

      $scope.allProducts.forEach(function (product) {
        if (!product.sub_category) return;
        var id = product.sub_category.id;
        counts[id] = (counts[id] || 0) + 1;
      });

      $scope.subCategoryCounts = counts;
    }

    function updatePagination() {
      $scope.totalPages = Math.max(1, Math.ceil($scope.products.length / PAGE_SIZE));
      $scope.pageNumbers = Array.from({ length: $scope.totalPages }, function (_, i) {
        return i + 1;
      });
      $scope.currentPage = 1;
    }

    // Load all products for this category
    ProductService.getAll(category_id)
      .then(function (response) {
        $scope.allProducts = response.data;
        $scope.products = response.data;
        computeSubCategoryCounts();
        updatePagination();
      })
      .catch(function (error) {
        $scope.error = error.data?.error || "Failed to load products";
      })
      .finally(function () {
        $scope.loading = false;
      });

    // Load sub-categories for the filters sidebar
    SubCategoryService.getByCategory(category_id)
      .then(function (response) {
        $scope.subCategories = response.data;
      })
      .catch(function (error) {
        console.log(error);
      });

    // Re-filter the product list whenever a sub-category checkbox is toggled.
    // No sub-categories checked = show everything.
    $scope.onFilterChange = function () {
      var activeIds = Object.keys($scope.selectedSubCategoryIds).filter(function (id) {
        return $scope.selectedSubCategoryIds[id];
      });

      if (activeIds.length === 0) {
        $scope.products = $scope.allProducts;
      } else {
        $scope.products = $scope.allProducts.filter(function (product) {
          return product.sub_category && activeIds.indexOf(String(product.sub_category.id)) !== -1;
        });
      }

      updatePagination();
    };

    // Pagination is UI-only: it just moves the highlighted page indicator.
    $scope.goToPage = function (page) {
      // console.log(page)
      if (page < 1 || page > $scope.totalPages) return;
      $scope.currentPage = page;
    };

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
