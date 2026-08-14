app.controller(
  'HomeController',
  function ($scope, CategoryService, AuthService, $location) {
    $scope.categories = [];
    $scope.error = null;
    $scope.loading = true;

    var token = AuthService.getToken();
    if (!token) {
      $location.path('/login');
      return;
    }

    CategoryService.getAll()
      .then(function (response) {
        $scope.categories = response.data;
      })
      .catch(function (error) {
        $scope.error = error.data?.error || 'Failed to load categories';
      })
      .finally(function () {
        $scope.loading = false;
      });

    $scope.viewCategory = function (category) {
      $location.path('/products');
    };
  },
);
