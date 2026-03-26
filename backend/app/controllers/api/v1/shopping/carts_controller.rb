class Api::V1::Shopping::CartsController < Api::V1::BaseController
  before_action :ensure_customer!

  def show
    @cart = current_user.cart

    if @cart
      render json: @cart.as_json(
        include: {
          cart_items: {
            include: {
              product: { only: [:id, :name, :price] },
            },
            only: [:id, :quantity, :price],
          },
        },
        only: [:id, :user_id, :status, :total],
      )
    else
      render json: { error: "No cart create one!" }
    end
  end

  def create
    if current_user.cart.present?
      render json: { message: "Cart already exists!" }, status: :ok
    else
      @cart = current_user.create_cart

      if @cart.persisted?
        render json: { message: "Cart created!" }
      else
        render json: { error: @cart.errors.full_messages }
      end
    end
  end

  def destroy
    if current_user.cart.present?
      @cart = current_user.cart
      @cart.destroy()
      render json: {
               message: "Deleted cart for user #{current_user.email}",
               cart: @cart,
             }
    else
      render json: { message: "Cart for user #{current_user.email} does not exist!" }
    end
  end
end
