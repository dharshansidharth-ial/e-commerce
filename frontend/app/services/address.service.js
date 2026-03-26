app.service("AddressService" , function($http , AuthService){
    BASE_URL = "http://localhost:3000/api/v1"

    function authHeaders(){
        return {
            headers: {
                Authorization: AuthService.getToken()
            }
        }
    }

    this.getAddress = function(user_id){
        return $http.get(BASE_URL + `/users/${user_id}/` + "addresses")
    }
})