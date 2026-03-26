class AddPriceToCartItem < ActiveRecord::Migration[8.1]
  def change
    add_column :shopping_cart_items , :price , :decimal
  end
end
