module Shopping
  class CartItem < ApplicationRecord
    after_commit :update_cart_total

    belongs_to :cart,
               class_name: "Shopping::Cart",
               foreign_key: :shopping_cart_id

    belongs_to :product,
               class_name: "Catalog::Product",
               foreign_key: :catalog_product_id

    def update_cart_total()
      return unless cart.present?
      return if cart.destroyed?

      cart.recalculate_total!()
    end
  end
end
