app.controller(
  'AuthController',
  function ($scope, $http, AuthService, $location) {
    $scope.user = {};
    const API_URL = 'http://localhost:3000/api/v1';

    $scope.login = function () {
      AuthService.login($scope.user)
        .then(function (response) {
          AuthService.saveAuthData(response.data.token, response.data.user);
          $location.path(AuthService.getDashboardPath());
        })
        .catch(function () {
          $scope.error = 'Invalid email or password';
        });
    };

    $scope.register = function () {
      $scope.error = null;
      $scope.success = null;

      if ($scope.user.password !== $scope.user.password_confirmation) {
        $scope.error = 'Passwords do not match';
        return;
      }

      $http
        .post(API_URL + '/auth/register', {
          user: $scope.user,
        })
        .then(function () {
          $scope.success = $scope.user.role === 'seller'
            ? 'Seller account created. Wait for admin approval before logging in.'
            : 'Registration successful. Please login.';
          $location.path($scope.user.role === 'seller' ? '/seller/login' : '/login');
        })
        .catch(function (error) {
          $scope.error = error.data?.errors || 'Registration failed';
        });
    };
  },
);
