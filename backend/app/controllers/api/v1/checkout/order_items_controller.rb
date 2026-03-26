class Api::V1::Checkout::OrderItemsController < Api::V1::BaseController
    before_action :set_order_item

    # def index
    #     render json: @order_items
    # end

    def show
        order_item_id = params[:id]
        order_item = @order.order_items.find_by(id: order_item_id)
        render json: order_item
    end

    def update
        # render json: params
        order_item = @order.order_items.find_by(id: params[:id])
        # product_id = order_item[:catalog_product_id]
        # product = Catalog::Product.find_by(id: product_id)
        product = order_item.product
        stock = product[:stock]
        new_quantity = params[:quantity]

        diff = new_quantity - order_item.quantity

        ActiveRecord::Base.transaction do 

            if diff > 0 && stock < diff
                render json: {msg: "hello"}
                # render json: {error: "Out of stock!"} , status: :unprocessable_entity
            end

            product.update!(stock: stock - diff)
            order_item.update!(quantity: new_quantity)

            
            recalc_order_total(@order)
            
            if product.save() && order_item.save()
                render json: {
                    message: "update success!",
                    order_item_id: order_item.id,
                    quantity: new_quantity
                }
            else
                render json: {
                    error: "something went wrong!",
                }
            end
        end
    
    end

    def destroy
        order_item = @order.order_items.find_by(id: params[:id])
        
        if order_item == nil
            render json: {message: "No order item found!"}, status: :not_found
            return 
        end

        product = order_item.product

        ActiveRecord::Base.transaction do
            product.update!(stock: product.stock + order_item.quantity)
            order_item.destroy()

            recalc_order_total(@order)
        end

        render json: {
            message: "Order item removed successfully!",
            removed_item: order_item
        }

    end

    private
    def set_order_item
        @order = current_user.orders.find_by(id: params[:order_id])
        @order_items = @order.order_items
    end

    def recalc_order_total(order)
        total = order.order_items.sum("price * quantity")
        order.update!(total_amount: total)
    end

end
