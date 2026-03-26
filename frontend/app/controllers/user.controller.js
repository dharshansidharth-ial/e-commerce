angular.module("app").controller(
  "UserController",
  function ($scope, $http, AuthService, $location) {
    const API_URL = "http://localhost:3000/api/v1";

    $scope.user = {};
    $scope.error = null;
    $scope.success = null;

    // ----------------------------------
    // 🔐 Auth Guard
    // ----------------------------------
    function getAuthConfig() {
      const token = AuthService.getToken();

      if (!token) {
        $location.path("/login");
        return null;
      }

      return {
        headers: {
          Authorization: "Bearer " + token,
        },
      };
    }

    // ----------------------------------
    // 🔹 Load Current User
    // ----------------------------------
    function loadUser() {
      const config = getAuthConfig();
      if (!config) return;

      $http
        .get(API_URL + "/users/me", config)
        .then(function (response) {
          $scope.user = response.data;

          // Never bind password fields from backend
          $scope.user.password = "";
          $scope.user.password_confirmation = "";

          $scope.error = null;
        })
        .catch(function (error) {
          if (error.status === 401 || error.status === 403) {
            AuthService.logout();
            $location.path("/login");
          } else {
            $scope.error = "Failed to load profile";
          }
        });
    }

    loadUser();

    // ----------------------------------
    // 🔹 Update User
    // ----------------------------------
    $scope.updateUser = function () {
      const config = getAuthConfig();
      if (!config) return;

      $scope.error = null;
      $scope.success = null;

      let payload = {
        email: $scope.user.email,
      };

      // Only send password if entered
      if ($scope.user.password && $scope.user.password_confirmation) {
        payload.password = $scope.user.password;
        payload.password_confirmation = $scope.user.password_confirmation;
      }

      $http
        .patch(API_URL + "/users/me", { user: payload }, config)
        .then(function (response) {
          $scope.user = response.data;
          $scope.user.password = "";
          $scope.user.password_confirmation = "";

          $scope.success = "Profile updated successfully";
        })
        .catch(function (error) {
          if (error.status === 401 || error.status === 403) {
            AuthService.logout();
            $location.path("/login");
          } else {
            $scope.error = error.data?.errors || "Update failed";
          }
        });
    };

    // ----------------------------------
    // 🔹 Delete User
    // ----------------------------------
    $scope.deleteUser = function () {
      const config = getAuthConfig();
      if (!config) return;

      $http
        .delete(API_URL + "/users/me", config)
        .then(function () {
          AuthService.logout();
          $location.path("/login");
        })
        .catch(function (error) {
          $scope.error = error.data?.error || "Delete failed";
        });
    };

    // ----------------------------------
    // 🔹 Logout
    // ----------------------------------
    $scope.logout = function () {
      AuthService.logout();
      $location.path("/login");
    };
    $scope.passwordData = {};

    $scope.updatePassword = function () {
      $scope.error = null;
      $scope.success = null;

      if (
        $scope.passwordData.new_password !==
        $scope.passwordData.new_password_confirmation
      ) {
        $scope.error = "New passwords do not match";
        return;
      }

      $http
        .patch(
          "http://localhost:3000/api/v1/users/update_password",
          {
            current_password: $scope.passwordData.current_password,
            password: $scope.passwordData.new_password,
            password_confirmation:
              $scope.passwordData.new_password_confirmation,
          },
          {
            headers: {
              Authorization: "Bearer " + AuthService.getToken(),
            },
          },
        )
        .then(function (response) {
          $scope.success = "Password updated successfully";
          $scope.passwordData = {};
        })
        .catch(function (error) {
          $scope.error = error.data?.error || "Password update failed";
        });
    };
  },
);
