app.factory('UserService', function($http) {

  const API_URL = "http://localhost:3000/api/v1";

  return {

    // ----------------------------------
    // 🔹 Get Current Logged-in User
    // ----------------------------------
    getCurrentUser: function() {
      return $http.get(API_URL + '/users/me');
    },

    // ----------------------------------
    // 🔹 Update Current User
    // ----------------------------------
    updateCurrentUser: function(userData) {

      let payload = {
        email: userData.email
      };

      // Only send password if present
      if (userData.password && userData.password_confirmation) {
        payload.password = userData.password;
        payload.password_confirmation = userData.password_confirmation;
      }

      return $http.patch(
        API_URL + '/users/me',
        { user: payload }
      );
    },

    // ----------------------------------
    // 🔹 Delete Current User
    // ----------------------------------
    deleteCurrentUser: function() {
      return $http.delete(API_URL + '/users/me');
    }

  };

});
