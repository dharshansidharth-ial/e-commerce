class Order::UpdateService
    def initialize(order: , address_id: , phone_number_id: , current_user:)
        @order = order
        @address_id = address_id
        @phone_number_id = phone_number_id
        @current_user = current_user
        @status
        # return @order
    end

    def call
        ActiveRecord::Base.transaction do
            address = @current_user.addresses.find_by(id: @address_id)
            phone_number = @current_user.phone_numbers.find_by(id: @phone_number_id)

            @order.update(
                address_id: @address_id,
                phone_number_id: @phone_number_id
            )

            return @order.save()
        end
    end

end