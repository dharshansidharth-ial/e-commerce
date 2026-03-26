class RenameTables < ActiveRecord::Migration[8.1]
  def change
    rename_table :products , :catalog_products
    rename_table :categories , :catalog_categories

    rename_table :orders , :checkout_orders
    rename_table :order_items , :checkout_order_items

    rename_table :carts , :shopping_carts
    rename_table :cart_items , :shopping_cart_items

    rename_table :reviews , :feedback_reviews
  end
end
