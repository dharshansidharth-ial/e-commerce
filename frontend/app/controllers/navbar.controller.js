angular
  .module('app')
  .controller('NavbarController', function ($scope, $location, $rootScope, $document, $http, AuthService) {
    var API_URL = 'http://localhost:3000/api/v1';

    function updateAuthState() {
      var token = AuthService.getToken();
      $scope.loggedIn = !!(token && token !== 'false' && token !== '');
      $rootScope.loggedIn = $scope.loggedIn;
    }

    $scope.profileMenuOpen = false;
    $scope.currentUser = {};

    $scope.isAdmin = function () {
      return AuthService.isAdmin();
    };

    $scope.isSeller = function () {
      return AuthService.isSeller();
    };

    $scope.isCustomer = function () {
      return AuthService.isCustomer();
    };

    $scope.isActive = function (path) {
      return $location.path() === path;
    };

    function loadCurrentUser() {
      var token = AuthService.getToken();
      if (!token || !$scope.isCustomer()) return;

      $http
        .get(API_URL + '/users/me', {
          headers: { Authorization: 'Bearer ' + token },
        })
        .then(function (response) {
          $scope.currentUser = response.data;
        });
    }

    $scope.toggleProfileMenu = function () {
      $scope.profileMenuOpen = !$scope.profileMenuOpen;
    };

    $scope.closeProfileMenu = function () {
      $scope.profileMenuOpen = false;
    };

    updateAuthState();
    loadCurrentUser();

    $scope.$on('$routeChangeSuccess', function () {
      updateAuthState();
      loadCurrentUser();
    });

    $scope.logout = function () {
      AuthService.logout();
      $scope.loggedIn = false;
      $rootScope.loggedIn = false;
      $scope.profileMenuOpen = false;
      $location.path('/login');
    };

    $document.on('click', function (event) {
      const menu = document.querySelector('.profile-container');

      if (menu && !menu.contains(event.target)) {
        $scope.$apply(function () {
          $scope.profileMenuOpen = false;
        });
      }
    });
  });
