app.controller(
  'AdminController',
  function ($scope, $location, $q, AuthService, AdminService) {
    $scope.credentials = {};
    $scope.products = [];
    $scope.orders = [];
    $scope.reviews = [];
    $scope.sellers = [];
    $scope.categories = [];
    $scope.orderStatuses = ['pending', 'paid', 'shipped', 'delivered' , 'cancelled'];
    $scope.sellerStatuses = ['pending', 'approved', 'suspended'];
    $scope.productForm = {
      active: true,
      stock: 0,
    };
    $scope.formMode = 'create';
    $scope.loading = false;
    $scope.error = null;
    $scope.success = null;
    $scope.categoryForm = {};
    $scope.createCategoryOn = false

    function setMessage(type, message) {
      $scope.error = type === 'error' ? message : null;
      $scope.success = type === 'success' ? message : null;
    }

    function ensureAdmin() {
      return AdminService.getCurrentUser().then(function (response) {
        if (response.data.role !== 'admin') {
          AuthService.logout();
          setMessage('error', 'Admin access only.');
          $location.path('/admin/login');
          throw new Error('not-admin');
        }

        $scope.currentAdmin = response.data;
        return response.data;
      });
    }

    function loadDashboard() {
      $scope.loading = true;
      $scope.error = null;

      return ensureAdmin()
        .then(function () {
          return $q.all([
            AdminService.getProducts(),
            AdminService.getOrders(),
            AdminService.getReviews(),
            AdminService.getCategories(),
            AdminService.getSellers(),
          ]);
        })
        .then(function (responses) {
          $scope.products = responses[0].data;
          $scope.orders = responses[1].data;
          $scope.reviews = responses[2].data;
          $scope.categories = responses[3].data;
          $scope.sellers = responses[4].data;
        })
        .catch(function (error) {
          if (error && error.message === 'not-admin') {
            return;
          }

          $scope.error = error.data?.error || error.data?.errors || 'Failed to load admin dashboard.';
        })
        .finally(function () {
          $scope.loading = false;
        });
    }

    $scope.changeCreateCategoryOn = function (){
      console.log("in createCategory")
      $scope.createCategoryOn = !$scope.createCategoryOn
    }

    $scope.submitCategory = function(){
      AdminService.createCategory($scope.categoryForm)
      .then((res) => {
        alert("Created category!")
      })
      .catch((err) => {
        console.error(err)
      })
    }

    $scope.deleteCategory = function(cid){
      AdminService.deleteCategory(cid)
      .then((res) => {
        alert("Deletion success!")
      })
      .catch((err) => {
        console.error(err)
      })
    }

    $scope.login = function () {
      $scope.error = null;
      $scope.success = null;

      AuthService.login($scope.credentials)
        .then(function (response) {
          AuthService.saveAuthData(response.data.token, response.data.user);

          if (response.data.user && response.data.user.role === 'admin') {
            $location.path('/admin');
          } else {
            AuthService.logout();
            $scope.error = 'This account is not an admin account.';
          }
        })
        .catch(function (error) {
          $scope.error = error.data?.error || 'Invalid admin credentials.';
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
        catalog_category_id: product.catalog_category_id,
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
      const action = $scope.formMode === 'edit'
        ? AdminService.updateProduct($scope.productForm)
        : AdminService.createProduct($scope.productForm);

      action
        .then(function () {
          setMessage('success', $scope.formMode === 'edit' ? 'Product updated.' : 'Product created.');
          $scope.resetProductForm();
          loadDashboard();
        })
        .catch(function (error) {
          const message = error.data?.errors || error.data?.error || 'Failed to save product.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.deleteProduct = function (productId) {
      AdminService.deleteProduct(productId)
        .then(function (response) {
          setMessage('success', response.data.message || 'Product deleted.');
          loadDashboard();
        })
        .catch(function (error) {
          const message = error.data?.errors || error.data?.error || 'Failed to delete product.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.updateOrderStatus = function (order) {
      AdminService.updateOrderStatus(order.id, order.status)
        .then(function () {
          setMessage('success', 'Order status updated.');
          loadDashboard();
        })
        .catch(function (error) {
          const message = error.data?.errors || error.data?.error || 'Failed to update order.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.deleteReview = function (reviewId) {
      AdminService.deleteReview(reviewId)
        .then(function () {
          setMessage('success', 'Review deleted.');
          loadDashboard();
        })
        .catch(function (error) {
          const message = error.data?.errors || error.data?.error || 'Failed to delete review.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.updateSellerStatus = function (seller) {
      AdminService.updateSellerStatus(seller.id, seller.seller_status)
        .then(function () {
          setMessage('success', 'Seller status updated.');
          loadDashboard();
        })
        .catch(function (error) {
          const message = error.data?.errors || error.data?.error || 'Failed to update seller.';
          setMessage('error', Array.isArray(message) ? message.join(', ') : message);
        });
    };

    $scope.setSellerStatus = function (seller, status) {
      seller.seller_status = status;
      $scope.updateSellerStatus(seller);
    };

    $scope.logoutAdmin = function () {
      AuthService.logout();
      $location.path('/admin/login');
    };

    if ($location.path() === '/admin') {
      loadDashboard();
    }
  },
);
