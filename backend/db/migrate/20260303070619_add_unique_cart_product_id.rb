class AddUniqueCartProductId < ActiveRecord::Migration[8.1]
  def change
    add_index :shopping_cart_items, [:shopping_cart_id, :catalog_product_id], unique: true
  end
end
