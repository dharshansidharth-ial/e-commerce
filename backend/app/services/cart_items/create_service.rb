class CartItems::CreateService
  def initialize(user:, product_id:, quantity:)
    @user = user
    @product = Catalog::Product.lock.find_by(id: product_id)
    @quantity = quantity.to_i
  end

  def call
    return error("Product not found!") unless @product
    return error("Quantity must be at least 1") if @quantity <= 0

    ActiveRecord::Base.transaction do
      cart = @user.cart || @user.create_cart

      cart_item = cart.cart_items.find_by(
        catalog_product_id: @product.id
      )

      new_quantity = cart_item ? cart_item.quantity + @quantity : @quantity

      return error("Insufficient stock!") if new_quantity > @product.stock

      if cart_item
        cart_item.update!(
          quantity: new_quantity,
          price: @product.price
        )
        message = "Cart item updated successfully!"
      else
        cart.cart_items.create!(
          catalog_product_id: @product.id,
          quantity: new_quantity,
          price: @product.price
        )
        message = "Product added to cart successfully!"
      end

      success(cart.reload, message)
    end

  rescue ActiveRecord::RecordInvalid => e
    error(e.record.errors.full_messages)
  end

  private

  def error(message)
    {
      success: false,
      error: message
    }
  end

  def success(cart, message)
    {
      success: true,
      message: message,
      cart: cart,
      cart_total: cart_total(cart)
    }
  end

  def cart_total(cart)
    cart.cart_items.sum("quantity * price")
  end
end
