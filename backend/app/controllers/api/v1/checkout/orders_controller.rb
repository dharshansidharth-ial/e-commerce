class Api::V1::Checkout::OrdersController < Api::V1::BaseController
  before_action :ensure_customer!
  before_action :set_orders
  before_action :set_order , only: [:show , :cancel]

  def index
    render json: @orders, include: {
             order_items: {
               include: {
                 product: {
                   only: [:name],
                 },
               },
             },
           }
  end

  def show
   
    # render json: order
    # address_id = order[:address_id]
    # phone_number_id = order[:phone_number_id]
    # address = Address.find_by(id: address_id)
    # phone_number = PhoneNumber.find_by(id: phone_number_id)

    # render json: {addr: address , phn: phone_number}

    # render json: @order

    render json: @order, include: {
             order_items: {
               include: {
                 product: {
                   only: [:name],
                 },
               },
             },
             address: {},
             phone_number: {},
           }
  end

  def create
    res = ::Order::CreateService.new(
      cart: current_user.cart,
      current_user: current_user,
      address_id: params[:address_id],
      phone_number_id: params[:phone_number_id],
    ).call

    render json: res, include: :order_items, status: :created
    # puts params[:phone_number_id]
  end

  def update
    order_id = params[:id]
    order = @orders.find_by!(id: order_id)

    if order.update!(order_update_params)
      render json: {
               message: "update success!",
               address_id: params[:address_id],
               phone_number: params[:phone_number_id],
             }
    else
      render json: {
               error: "Update failed!",
               message: res.errors.full_messages,
             }

    end

    # address_id = params[:address_id]
    # phone_number_id = params[:phone_number_id]

    # # render json: current_user
    # address = current_user.addresses.find_by(id: address_id)
    # phone_number = current_user.phone_numbers.find_by(id: phone_number_id)
    # # render json: {
    # #     addr: address ,
    # #     ph: phone_number,
    # # }
    # order = current_user.orders.find_by(id: order_id)
    # # render json: order
    # res = ::Order::UpdateService.new(
    #   order: order,
    #   address_id: address_id,
    #   phone_number_id: phone_number_id,
    #   status: status,
    #   current_user: current_user,
    # ).call

    # if res
    #   render json: {
    #            message: "update success!",
    #            address: address,
    #            phone_number: phone_number,
    #          }
    # else
    #   render json: {
    #            error: "Update failed!",
    #            message: res.errors.full_messages,
    #          }
    # end
  end

  def cancel
    if @order.update!(status: "cancelled")
      ActiveRecord::Base.transaction do

        @order.order_items.each do |item|
          product = Catalog::Product.find_by!(id: item.catalog_product_id)
          product.update(stock: product.stock + item.quantity)
        end



      end
    else

    end
  end

  # def destroy
  #   order_id = params[:id]
  #   # render plain: order_id
  #   order = current_user.orders.find_by(id: order_id)
  #   # render json: order , include: :order_items

  #   if order.nil?
  #     render json: { message: "No orders found with id: #{order_id}" }
  #     return
  #   end

  #   ActiveRecord::Base.transaction do
  #     order.order_items.each do |item|
  #       product = item.product
  #       product.update!(stock: product.stock + item.quantity)
  #     end
  #   end

  #   if order&.destroy()
  #     render json: {
  #              message: "Deletion success!",
  #              deleted_order: order,
  #            }
  #   else
  #     render json: {
  #              message: "something went wrong!",
  #              error: order&.errors&.full_messages,
  #            }
  #   end
  # end

  private

  def order_update_params
    params.require(:order).permit(:address_id , :phone_number_id)
  end

  def order_cancel_params()
    params.require(:order).permit(:status)
  end

  def set_order
    @order = @orders.find_by!(id: params[:id])
  end

  def set_orders
    @orders = current_user.orders
  end
end
