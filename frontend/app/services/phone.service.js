app.service("PhoneService" , function(AuthService , $http){
    BASE_URL = "http://localhost:3000/api/v1"

    this.getPhone = function(user_id){
        return $http.get(BASE_URL + `/users/${user_id}` + "/phone_numbers")
    }
})