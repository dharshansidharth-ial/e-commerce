class CartItems::UpdateService
  def initialize(cart_item:, quantity:)
    @cart_item = cart_item
    @quantity = quantity
    @product = cart_item.product
  end

  def call()
    return error("Quantity cannot be negative!") if @quantity <= 0
    return error("Out of stock!") if @quantity > @product.stock

    ActiveRecord::Base.transaction do 
      if @quantity == 0
        @cart_item.destroy!()        
      else
        @cart_item.update(quantity: @quantity)
      end

      success(@cart_item.cart.reload , "update successful!")

    end

  rescue ActiveRecord::RecordInvalid => e
    error(e.error.full_messages)
  end

  private

  def error(message)
    {
      success: false,
      error: message,
    }
  end

  def success(cart , message)
    {
      success: true,
      cart: cart,
      message: message,
    }
  end

end
