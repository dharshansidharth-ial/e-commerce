module Shopping
  class Cart < ApplicationRecord
    belongs_to :user,
               foreign_key: :user_id

    has_many :cart_items,
             foreign_key: :shopping_cart_id,
             class_name: "Shopping::CartItem",
             dependent: :destroy

    has_many :products,
             foreign_key: :shopping_cart_id,
             through: :cart_items,
             source: :product

    def recalculate_total!
      update!(
        total: cart_items.sum("price * quantity")
      )
    end

   
  end
end
