module Checkout
  class OrderItem < ApplicationRecord
    validate :product_must_be_available
    after_save :update_order_total
    belongs_to :order,
               class_name: "Checkout::Order",
               foreign_key: :checkout_order_id

    belongs_to :product,
               class_name: "Catalog::Product",
               foreign_key: :catalog_product_id


    private
    def update_order_total()
       order.recalculate_total!
    end

    def product_must_be_available()
      unless product&.available_for_sale
        errors.add(:base , "Product not available!")
      end
    end

  end
end
