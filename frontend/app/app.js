var app = angular.module("app", ["ngRoute"]);

app.config(function ($routeProvider, $httpProvider) {
  $routeProvider
    .when("/login", {
      templateUrl: "app/views/auth/login.html",
      controller: "AuthController",
    })
    .when("/admin/login", {
      templateUrl: "app/views/admin/login.html",
      controller: "AdminController",
    })
    .when("/seller/login", {
      templateUrl: "app/views/seller/login.html",
      controller: "SellerController",
    })
    .when("/admin", {
      templateUrl: "app/views/admin/dashboard.html",
      controller: "AdminController",
    })
    .when("/seller", {
      templateUrl: "app/views/seller/dashboard.html",
      controller: "SellerController",
    })
    .when("/register", {
      templateUrl: "app/views/auth/register.html",
      controller: "AuthController",
    })
    .when("/profile", {
      templateUrl: "app/views/users/profile.html",
      controller: "UserController",
    })
    .when("/orders", {
      templateUrl: "app/views/orders/index.html",
      controller: "CheckoutController",
    })
    .when("/orders/:id", {
      templateUrl: "app/views/orders/show.html",
      controller: "OrderController",
    })
    .when("/products", {
      templateUrl: "app/views/products/index.html",
      controller: "ProductsController",
    })
    .when("/products/:id", {
      templateUrl: "app/views/products/show.html",
      controller: "ProductDetailController",
    })
    .when("/cart", {
      templateUrl: "app/views/cart/index.html",
      controller: "CartController",
    })
    .when("/checkout", {
      templateUrl: "app/views/orders/checkout.html",
      controller: "CheckoutController",
    })
    .when("/info", {
      templateUrl: "app/views/info/index.html",
      controller: "InfoController",
    })
    .otherwise({
      redirectTo: "/login",
    });

  $httpProvider.interceptors.push("AuthInterceptor");
});

angular.module("app").factory("AuthInterceptor", function () {
  return {
    request: function (config) {
      var token =
        localStorage.getItem("token") || sessionStorage.getItem("token");

      if (token) {
        config.headers = config.headers || {};
        config.headers.Authorization = "Bearer " + token;
      }

      return config;
    },
  };
});

app.run(function ($rootScope, $location, AuthService) {
  function isAuthenticated() {
    var token = AuthService.getToken();
    return !!(token && token !== "false" && token !== "");
  }

  $rootScope.loggedIn = isAuthenticated();

  $rootScope.$on("$routeChangeStart", function (event, next) {
    if (!next || !next.originalPath) return;

    var path = next.originalPath;
    var loggedIn = isAuthenticated();

    var adminRoute = path.indexOf("/admin") === 0 && path !== "/admin/login";
    var sellerRoute = path.indexOf("/seller") === 0 && path !== "/seller/login";
    var customerOnlyRoute =
      path === "/cart" ||
      path === "/checkout" ||
      path === "/orders" ||
      path === "/orders/:id";
    var publicRoute =
      path === "/login" || path === "/register" || path === "/admin/login" || path === "/seller/login";

    $rootScope.loggedIn = loggedIn;

    if (adminRoute && !loggedIn) {
      event.preventDefault();
      $location.path("/admin/login");
      return;
    }

    if (sellerRoute && !loggedIn) {
      event.preventDefault();
      $location.path("/seller/login");
      return;
    }

    if (adminRoute && loggedIn && !AuthService.isAdmin()) {
      event.preventDefault();
      $location.path(AuthService.getDashboardPath());
      return;
    }

    if (sellerRoute && loggedIn && !AuthService.isSeller()) {
      event.preventDefault();
      $location.path(AuthService.getDashboardPath());
      return;
    }

    if (customerOnlyRoute && loggedIn && !AuthService.isCustomer()) {
      event.preventDefault();
      $location.path(AuthService.getDashboardPath());
      return;
    }

    if (path === "/admin/login" && loggedIn && AuthService.isAdmin()) {
      event.preventDefault();
      $location.path("/admin");
      return;
    }

    if (path === "/seller/login" && loggedIn && AuthService.isSeller()) {
      event.preventDefault();
      $location.path("/seller");
      return;
    }

    if ((path === "/login" || path === "/register") && loggedIn) {
      event.preventDefault();
      $location.path(AuthService.getDashboardPath());
      return;
    }

    if (!publicRoute && !adminRoute && !sellerRoute && !loggedIn) {
      event.preventDefault();
      $location.path("/login");
    }
  });
});
