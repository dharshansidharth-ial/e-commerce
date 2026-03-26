module Catalog
  class Product < ApplicationRecord
    after_update :remove_from_carts, if: -> { saved_change_to_active? && !active }

    belongs_to :category,
               foreign_key: :catalog_category_id,
               class_name: "Catalog::Category"

    belongs_to :seller,
               class_name: "User",
               optional: true

    has_many :cart_items,
             foreign_key: :catalog_product_id,
             class_name: "Shopping::CartItem",
             dependent: :destroy

    has_many :order_items,
             foreign_key: :catalog_product_id,
             class_name: "Checkout::OrderItem"

  has_many :reviews,
             foreign_key: :catalog_product_id,
             class_name: "Feedback::Review",
             dependent: :destroy

    has_many :orders,
             through: :order_items,
             source: :order

    def in_stock()
      stock > 0
    end

    def available_for_sale()
      active && stock > 0
    end

    def revenue
      order_items
        .joins(:order)
        .merge(Checkout::Order.where(status: %i[paid shipped delivered]))
        .sum("checkout_order_items.price * checkout_order_items.quantity")
    end

    private

    def remove_from_carts
      cart_items = order_items
        .includes(:order)
        .joins(:order)
        .where(checkout_orders: { status: "cart" })

      cart_items.find_each do |item|
        order = item.order
        item.destroy
        order.recalculate_total!
      end
    end
  end
end
