app.factory('AuthService', function ($http) {
  var API_URL = 'http://localhost:3000/api/v1';

  function readToken() {
    return localStorage.getItem('token') || sessionStorage.getItem('token');
  }

  function  readRole() {
    return localStorage.getItem('role') || sessionStorage.getItem('role');
  }

  function persistAuth(token, user) {
    localStorage.setItem('token', token);
    sessionStorage.setItem('token', token);

    if (user && user.role) {
      localStorage.setItem('role', user.role);
      sessionStorage.setItem('role', user.role);
    }
  }

  function clearAuth() {
    sessionStorage.removeItem('token');
    localStorage.removeItem('token');
    sessionStorage.removeItem('role');
    localStorage.removeItem('role');
  }

  function readRoleRoute() {
    var role = readRole();

    if (role === 'admin') return '/admin';
    if (role === 'seller') return '/seller';
    return '/products';
  }

  function readLoginRoute() {
    return readRole() === 'admin' ? '/admin/login' : readRole() === 'seller' ? '/seller/login' : '/login';
  }

  return {
    login: function (credentials) {
      return $http.post(API_URL + '/auth/login', credentials);
    },

    register: function (user) {
      return $http.post(API_URL + '/auth/register', {
        user: user,
      });
    },

    saveAuthData: function (token, user) {
      persistAuth(token, user);
    },

    saveToken: function (token) {
      persistAuth(token, null);
    },

    getToken: function () {
      return readToken();
    },

    getRole: function () {
      return readRole();
    },

    isAdmin: function () {
      return readRole() === 'admin';
    },

    isSeller: function () {
      return readRole() === 'seller';
    },

    isCustomer: function () {
      return readRole() === 'customer';
    },

    getDashboardPath: function () {
      return readRoleRoute();
    },

    getLoginPath: function () {
      return readLoginRoute();
    },

    logout: function () {
      clearAuth();
    },
  };
});
