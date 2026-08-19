app.controller(
  "ProductsController",
  function ($scope, ProductService, SubCategoryService, CartService, AuthService, $location, $routeParams) {
    $scope.products = [];
    $scope.subCategories = [];
    $scope.subCategoryCounts = {};
    $scope.selectedSubCategoryIds = {};
    $scope.error = null;
    $scope.loading = true;
    $scope.isCustomer = AuthService.isCustomer();

    var PAGE_SIZE = 10;
    $scope.currentPage = 1;
    $scope.totalPages = 1;
    $scope.pageNumbers = [1];

    const category_id = $routeParams.category_id;

    const token = AuthService.getToken();
    if (!token) {
      $location.path("/login");
      return;
    }

    function buildParams(page) {
      var params = { page: page, per_page: PAGE_SIZE };

      var activeIds = Object.keys($scope.selectedSubCategoryIds).filter(function (id) {
        return $scope.selectedSubCategoryIds[id];
      });
      if (activeIds.length) {
        params.sub_category_ids = activeIds.join(",");
      }

      return params;
    }

    // Products and their metadata (pagination + per-subcategory counts) come
    // from two separate endpoints, so they're fetched independently instead
    // of being merged into a single $scope.products array.
    function loadProducts(page) {
      $scope.loading = true;
      var params = buildParams(page);

      ProductService.getAll(category_id, params)
        .then(function (response) {
          $scope.products = response.data.products;
        })
        .catch(function (error) {
          $scope.error = error.data?.error || "Failed to load products";
        })
        .finally(function () {
          $scope.loading = false;
        });

      ProductService.getMetadata(category_id, params)
        .then(function (response) {
          var meta = response.data.meta;
          $scope.metadata = meta;
          $scope.subCategoryCounts = meta.sub_category_counts || {};
          $scope.currentPage = meta.current_page;
          $scope.totalPages = meta.total_pages;
          $scope.pageNumbers = Array.from({ length: $scope.totalPages }, function (_, i) {
            return i + 1;
          });
        })
        .catch(function (error) {
          console.log(error);
        });
    }

    loadProducts($scope.currentPage);

    // Load sub-categories for the filters sidebar
    SubCategoryService.getByCategory(category_id)
      .then(function (response) {
        $scope.subCategories = response.data;
      })
      .catch(function (error) {
        console.log(error);
      });

    // Re-fetch from the backend whenever a sub-category checkbox is toggled.
    // No sub-categories checked = show everything.
    $scope.onFilterChange = function () {
      loadProducts(1);
    };

    $scope.goToPage = function (page) {
      if (page < 1 || page > $scope.totalPages) return;
      loadProducts(page);
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
      // console.log(product)

      $location.path(`/category/${category_id}/sub_category/${product['sub_category']['id']}/product/${product.id}`);
    };
  },
);
