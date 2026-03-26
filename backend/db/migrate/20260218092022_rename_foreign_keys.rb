class RenameForeignKeys < ActiveRecord::Migration[8.1]
  def change
    rename_column :catalog_products , :category_id , :catalog_category_id

    rename_column :checkout_order_items , :order_id , :checkout_order_id
    rename_column :checkout_order_items , :product_id , :catalog_product_id
    
    rename_column :feedback_reviews, :product_id , :catalog_product_id
    
    rename_column :shopping_cart_items , :cart_id , :shopping_cart_id
    rename_column :shopping_cart_items , :product_id , :catalog_product_id
    
  end
end
