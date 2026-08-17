app.controller(
  'SubCategoriesController',
  function ($scope, SubCategoriesService, AuthService, $location) {
    $scope.sub_categories = [];
    $scope.error = null;
    $scope.loading = true;
    // $scope.cid = true;


    var token = AuthService.getToken();
    if (!token) {
      $location.path('/login');
      return;
    }

    SubCategoriesService.getAll()
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
      // console.log(category)
      $location.path(`/category/${category.id}/sub_categories`);
    };
  },
);
