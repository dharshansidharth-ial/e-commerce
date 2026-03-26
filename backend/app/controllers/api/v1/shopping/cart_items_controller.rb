class Api::V1::Shopping::CartItemsController < Api::V1::BaseController
  before_action :ensure_customer!
  before_action :set_cart
  before_action :set_cart_item, only: [:show, :update, :destroy]

  def index
    @cart_items = current_user.cart&.cart_items || []
    render json: @cart_items
  end

  def show
    return not_found unless @cart_item
    render json: @cart_item
  end

  def create
    # @cart = current_user.cart || current_user.create_cart
    # @product = params.dig(:cart_item, :product)
    # @quantity = params.dig(:cart_item, :quantity)

    # # render json: @quantity

    # return render json: { error: "Product not found!" } unless @product
    # return render json: { error: "Quantity is must!" } unless @quantity

    # @present_item = current_user.cart.cart_items.find_by(catalog_product_id: @product[:id])
    # if @present_item
    #   @present_item[:quantity] += 1
    #   if @present_item.save
    #     addition_success()
    #   else
    #     show_errors()
    #   end

    # #   render json: { item: @present_item }
    # else
    #   @cart_item = current_user.cart.cart_items.create(
    #     catalog_product_id: @product[:id],
    #     quantity: @quantity,
    #     price: @product[:price],
    #   )
    #   addition_success()

    # render plain: "hello"

    puts "in cart_items_controller#create"

    result = ::CartItems::CreateService.new(
      user: current_user,
      product_id: params.dig(:cart_item, :product_id),
      quantity: params.dig(:cart_item, :quantity),
    ).call

    if result[:success]
      render json: result, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def update
    return not_found unless @cart_item

    res = ::CartItems::UpdateService.new(
      cart_item: @cart_item,
      quantity: params.dig(:cart_item, :quantity),
    ).call

    # render json: res

    if res[:success]
      render json: res, status: :ok
    else
      render json: { error: res[:error] }, status: :unprocessable_entity
    end
  end

  def destroy
    if @cart_item
      @cart_item.destroy!
      render json: { message: "Cart item removed successfully!" }, status: :ok
    else
      not_found
    end
  end

  private

  def set_cart()
    @cart = current_user.cart || current_user.create_cart
  end

  def set_cart_item()
    @cart_item = current_user.cart&.cart_items&.find_by(id: params[:id])
  end

  def addition_success()
    render json: { message: "Added to cart!" }, status: :ok
  end

  def show_errors()
    render json: { error: @cart_item.errors.full_messages }
  end

  def not_found()
    render json: { error: "Cart Item not found!" }, status: :not_found
  end
end
