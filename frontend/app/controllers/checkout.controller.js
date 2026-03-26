app.controller(
  "CheckoutController",
  function (
    $scope,
    AuthService,
    CartService,
    OrderService,
    AddressService,
    PhoneService,
    $location,
  ) {
    $scope.cartItems = [];
    $scope.addresses = [];
    $scope.phoneNumbers = [];
    // $scope.showAddressForm = false
    $scope.ui = {
      showAddressForm: false,
      showPhoneForm: false,
    };
    $scope.newAddress = {};
    $scope.newPhone = {};

    const token = AuthService.getToken();
    const user_id = JSON.parse(atob(token.split(".")[1])).user_id;
    function loadOrders() {
      CartService.getCart()
        .then(function (res) {
          // console.log(res.data);
          $scope.cartItems = res.data.cart_items || [];

          // console.log($scope.cartItems)

          $scope.cartItems.forEach(function (item) {
            if (item.product) {
              item.product.price = Number(item.product.price);
            }
          });
          $scope.total = Number(res.data.total || 0);
        })
        .catch(function (err) {
          console.error(err);
        });

      AddressService.getAddress(user_id)
        .then(function (res) {
          // console.log(res.data , "addresses")
          $scope.addresses = res.data || [];
        })
        .catch(function (err) {
          console.error(err);
        });

      PhoneService.getPhone(user_id)
        .then(function (res) {
          $scope.phoneNumbers = res.data || [];
        })
        .catch(function (err) {
          console.error(err);
        });

      $scope.placeOrder = function () {
        const payload = {
          address_id: $scope.selectedAddress,
          phone_number_id: $scope.selectedPhone,
        };
        // console.log(payload);

        OrderService.placeOrder(payload)
          .then(function (res) {
            alert("Order placed! 🎉");
          })
          .catch(function (err) {
            console.log(err)
            console.error(err);
          });
      };

      $scope.addAddress = function () {
        OrderService.addAddress($scope.newAddress)
          .then(function (res) {
            console.log("done");
            $scope.newAddress = {}
            loadOrders()
          })
          .catch(function (err) {
            console.error(err);
          });
      };

      $scope.addPhone = () => {
        OrderService.addPhone($scope.newPhone)
        .then((res) => {
          console.log("done")
          loadOrders()
        })
        .catch((err) => {
          console.error(err)
        })
      }

      $scope.deleteAddress = function(event , id){
        if(event.type === 'click'){
          // console.log('in click')
          OrderService.deleteAddress(id)
          .then(function(res){
            alert("Removed address successfully")
            loadOrders()
          })
          .catch(function(err){
            console.error(err)
          })
        }
      }

      $scope.deletePhone = (event , phoneId) => {
        if(event.type === 'click'){
          OrderService.deletePhone(phoneId)
          .then((res) => {
            alert("phone number deleted!")
            loadOrders()
          })
          .catch((err) => {
            console.error(err)
          })
        }
      }
    }

    loadOrders()
  },
);
