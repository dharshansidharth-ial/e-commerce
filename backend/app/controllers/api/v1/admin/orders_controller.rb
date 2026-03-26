class Api::V1::Admin::OrdersController < Api::V1::BaseController
  before_action :authenticate_admin!
  before_action :set_order, only: [:show, :update]

  def index
    orders = Checkout::Order
      .includes(:user, :address, :phone_number, order_items: :product)
      .order(created_at: :desc)

    render json: serialize_orders(orders)
  end

  def show
    render json: serialize_order(@order)
  end

  def update
    if @order.update(order_params)
      if params.status == 'cancelled'
        puts @order
      end
      render json: { message: 'Order updated successfully.', order: serialize_order(@order.reload) }
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Checkout::Order.includes(:user, :address, :phone_number, order_items: :product).find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end

  def serialize_orders(orders)
    orders.map { |order| serialize_order(order) }
  end

  def serialize_order(order)
    order.as_json(
      include: {
        user: { only: [:id, :email, :role] },
        address: { only: [:id, :line1, :city, :country] },
        phone_number: { only: [:id, :phone_number, :verified] },
        order_items: {
          include: {
            product: { only: [:id, :name, :image_url] }
          },
          only: [:id, :catalog_product_id, :quantity, :price]
        }
      },
      only: [:id, :status, :total_amount, :created_at, :updated_at]
    )
  end
end
