class Order::CreateService
    def initialize(cart: , current_user: , address_id: , phone_number_id:)
        @current_user = current_user
        @address_id = address_id
        @phone_number_id = phone_number_id
        @cart = cart

        # puts @address_id
        # puts @phone_number_id
    end

    def call
        return {error: "cart is empty!"} , status: :unprocessable_entity if @cart.cart_items.empty?

        # puts @current_user.inspect
        address = @current_user.addresses.find_by(id: @address_id)
        phone_number = @current_user.phone_numbers.find_by(id: @phone_number_id)
        # print @address_id , "address"
        # print @phone_number_id , "phone_number"
        

        ActiveRecord::Base.transaction do
            order = @current_user.orders.create!(
                status: "pending",
                total_amount: 0,
                address: address,
                phone_number: phone_number,
            )

            total = 0

            @cart.cart_items.each do |item|
                product = item.product
                

                if product.stock < item.quantity
                    puts product.stock , item.quantity
                    puts "in order#createService"
                    raise ActiveRecord::Rollback
                end

                product.update!(stock: product.stock - item.quantity)

                order.order_items.create!(
                    catalog_product_id: product.id,
                    price: product.price,
                    quantity: item.quantity
                )

                total += product.price * item.quantity
            end
            order.update!(total_amount: total)

            @cart.cart_items.destroy_all()

            return order
        end

    end
end