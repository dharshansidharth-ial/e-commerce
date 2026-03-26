app.factory('AuthInterceptor', function($q, $location) {

  return {

    // ----------------------------------
    // 🔹 Attach JWT to every request
    // ----------------------------------
    request: function(config) {

      const token = localStorage.getItem("token");

      if (token) {
        config.headers = config.headers || {};
        config.headers.Authorization = "Bearer " + token;
      }

      return config;
    },

    // ----------------------------------
    // 🔹 Global Error Handling
    // ----------------------------------
    responseError: function(response) {

      if (response.status === 401 || response.status === 403) {

        // Token invalid / expired
        localStorage.removeItem("token");
        sessionStorage.removeItem("token");
        localStorage.removeItem("role");
        sessionStorage.removeItem("role");

        // Redirect to login
        $location.path("/login");
      }

      return $q.reject(response);
    }

  };

});
