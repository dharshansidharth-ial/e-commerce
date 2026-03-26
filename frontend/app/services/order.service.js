app.service("OrderService" , function($http){
    const BASE_URL = "http://localhost:3000/api/v1"

    this.placeOrder = (data) => {
        // console.log(data)
        return $http.post(BASE_URL + '/checkout/orders' , data)
    }

    this.getOrders = () => {
        return $http.get(BASE_URL + '/checkout/orders')
    }

    this.viewOrder = (orderId) => {
        return $http.get(BASE_URL + '/checkout/orders/' + orderId)
    }

    this.addAddress = (address) => {
        return $http.post(BASE_URL + '/users/me/addresses' , address)
    }

    this.addPhone = (phone) => {
        phone.verified = true
        return $http.post(BASE_URL + '/users/me/phone_numbers' , phone)
    }

    this.deleteAddress = (addressId) => {
        return $http.delete(BASE_URL + `/users/me/addresses/${addressId}`)
    }

    this.deletePhone = (phoneId) => {
        return $http.delete(BASE_URL + `/users/me/phone_numbers/${phoneId}`)
    }

    this.cancelOrder = (order) => {
        console.log(order)
        return $http.patch(BASE_URL + `/checkout/orders/${order.id}/cancel` , 
            {status: "cancelled"}
        )
    }
})