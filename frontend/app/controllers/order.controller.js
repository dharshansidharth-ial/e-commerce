app.controller(
  "OrderController",
  function ($scope, $location, $routeParams, $window, OrderService) {
    BASE_URL = "http://localhost:3000/api/v1";

    $scope.order = {};
    $scope.loading = true;
    $scope.cancelling = false;
    $scope.showCancelConfirm = false;
    $scope.editAddressMode = false
    $scope.editPhoneMode = false
    $scope.addresses = []

    $scope.$watch('editAddressMode' , (val) => {
      if(val && $scope.order?.address){
        $scope.selectedAddress = $scope.order.address.id
      }
    })

    // OrderService.getAddresses()
    // .then((res) => {

    // })
    // .catch((err) => {
    //   alert('cannot get addresses!')
    //   console.error(err)
    // })

    OrderService.getOrders().then(function (res) {
      // console.log(res.data)
      $scope.orders = res.data;
    });

    $scope.goToProduct = function (productId) {
      console.log(productId);
      if (!productId) {
        console.error("product not found");
        return;
      }

      $location.path("/products/" + productId);
    };

    $scope.viewOrder = function (orderId) {
      OrderService.viewOrder(orderId)
        .then(function (res) {
          console.log(res.data, "hello");
          $scope.order = res.data;
          $location.path("/orders/" + orderId);
        })
        .catch(function (err) {
          console.error(err);
        })
        .finally(function () {
          $scope.loading = false;
        });
    };

    $scope.confirmCancel = () => {
      $scope.showCancelConfirm = true;
    };

    $scope.hideCancelConfirm = () => {
      $scope.showCancelConfirm = false;
    };

    $scope.cancelOrder = (order) => {
      // console.log(order)
      OrderService.cancelOrder(order)
        .then((res) => {
          setTimeout(() => {
            alert("order cancelled!")
            $window.location.href = "http://localhost:8000/#!/orders";
          }, 800);
        })
        .catch((err) => {
          console.error(err);
        });
    };

    $scope.goBack = () => {
      $location.path("/orders");
    };

    const orderId = $routeParams.id;
    if (orderId) {
      $scope.viewOrder(orderId);
    } else {
      $scope.loading = false;
    }
  },
);

app.filter("capitalize", function () {
  return function (input) {
    return input ? input.charAt(0).toUpperCase() + input.slice(1) : "";
  };
});
