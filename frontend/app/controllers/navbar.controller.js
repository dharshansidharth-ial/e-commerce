angular
  .module('app')
  .controller('NavbarController', function ($scope, $location, $rootScope, $document, AuthService) {
    function updateAuthState() {
      var token = AuthService.getToken();
      $scope.loggedIn = !!(token && token !== 'false' && token !== '');
      $rootScope.loggedIn = $scope.loggedIn;
    }

    $scope.menuOpen = false;

    $scope.isAdmin = function () {
      return AuthService.isAdmin();
    };

    $scope.isSeller = function () {
      return AuthService.isSeller();
    };

    $scope.isCustomer = function () {
      return AuthService.isCustomer();
    };

    $scope.closeMenu = function () {
      $scope.menuOpen = false;
    };

    updateAuthState();

    $scope.$on('$routeChangeSuccess', function () {
      updateAuthState();
    });

    $scope.logout = function () {
      AuthService.logout();
      $scope.loggedIn = false;
      $rootScope.loggedIn = false;
      $location.path('/login');
    };

    $scope.toggleMenu = function () {
      $scope.menuOpen = !$scope.menuOpen;
    };

    $document.on('click', function (event) {
      const menu = document.querySelector('.menu-container');

      if (menu && !menu.contains(event.target)) {
        $scope.$apply(function () {
          $scope.menuOpen = false;
        });
      }
    });
  });
