app.controller('LoginController', function($scope, $http, AuthService, $location) {

  const API_URL = "http://localhost:3000/api/v1";

  $scope.user = {};
  $scope.error = null;

  $scope.login = function() {

    $scope.error = null;
    console.log("AuthController loaded");


    // 🔎 Basic validation
    if (!$scope.user.email || !$scope.user.password) {
      $scope.error = "Email and password are required";
      return;
    }

    $http.post(API_URL + "/login", {
      email: $scope.user.email,
      password: $scope.user.password
    })
    .then(function(response) {

      if (response.data.token) {

        AuthService.saveToken(response.data.token);

        // 🔐 Redirect to profile page
        $location.path('/profile');

      } else {
        $scope.error = "Token not received";
      }

    })
    .catch(function(error) {

      console.log(error);

      if (error.status === 401) {
        $scope.error = "Invalid email or password";
      } else {
        $scope.error = "Server error. Try again.";
      }

    });
  };

});
