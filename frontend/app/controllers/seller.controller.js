app.controller(
  'SellerController',
  function ($scope, $q, $location, AuthService, SellerService, AdminService) {
    $scope.credentials = {};
    $scope.currentSeller = null;
    $scope.metrics = {};
    $scope.products = [];
    $scope.reviews = [];
    $scope.categories = [];
    $scope.error = null;
    $scope.success = null;
    $scope.loading = false;
    $scope.formMode = 'create';
    $scope.productForm = {
      active: true,
      stock: 0,
    };

    function setMessage(type, message) {
      $scope.error = type === 'error' ? message : null;
      $scope.success = type === 'success' ? message : null;
    }

    function loadSellerProfile() {
      $scope.loading = true;
      $scope.error = null;

      return $q.all([
        SellerService.getDashboard(),
        AdminService.getCategories(),
      ])
        .then(function (responses) {
          var dashboard = responses[0].data;
          $scope.currentSeller = dashboard.seller;
          $scope.metrics = dashboard.metrics;
          $scope.products = dashboard.products;
          $scope.reviews = dashboard.reviews;
          $scope.categories = responses[1].data;
        })
        .catch(function (error) {
          AuthService.logout();
          $scope.error = error.data?.error || 'Unable to load seller dashboard.';
          $location.path('/seller/login');
        })
        .finally(function () {
          $scope.loading = false;
        });
    }

    $scope.login = function () {
      $scope.error = null;

      AuthService.login($scope.credentials)
        .then(function (response) {
          AuthService.saveAuthData(response.data.token, response.data.user);

          if (response.data.user && response.data.user.role === 'seller') {
            $location.path('/seller');
          } else {
            AuthService.logout();
            $scope.error = 'This account is not a seller account.';
          }
        })
        .catch(function (error) {
          $scope.error = error.data?.error || 'Invalid seller credentials.';
        });
    };

    $scope.startEditProduct = function (product) {
      $scope.formMode = 'edit';
      $scope.productForm = {
        id: product.id,
        name: product.name,
        description: product.description,
        price: Number(product.price || 0),
        stock: Number(product.stock || 0),
        active: !!product.active,
        catalog_category_id: product.catalog_category_id || product.category?.id,
        image_url: product.image_url || '',
      };
      setMessage(null, null);
    };

    $scope.resetProductForm = function () {
      $scope.formMode = 'create';
      $scope.productForm = {
        active: true,
        stock: 0,
      };
    };

    $scope.submitProduct = function () {
      var action = $scope.formMode === 'edit'
        ? SellerService.updateProduct($scope.productForm)
        : SellerService.createProduct($scope.productForm);

      action
        .then(function () {
          setMessage('success', $scope.formMode === 'edit' ? 'Product updated.' : 'Product listed successfully.');
          $scope.resetProductForm();
          loadSellerProfile();
        })
        .catch(function (error) {
          var message = error.data?.errors || error.data?.error || 'Failed to save product.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.deleteProduct = function (productId) {
      SellerService.deleteProduct(productId)
        .then(function (response) {
          setMessage('success', response.data.message || 'Product deleted.');
          loadSellerProfile();
        })
        .catch(function (error) {
          var message = error.data?.errors || error.data?.error || 'Failed to delete product.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.logoutSeller = function () {
      AuthService.logout();
      $location.path('/seller/login');
    };

    if ($location.path() === '/seller') {
      loadSellerProfile();
    }
  },
);
