class AddAllForeignKeys < ActiveRecord::Migration[8.0]
  def change
     add_foreign_key :shopping_carts, :users unless foreign_key_exists?(:shopping_carts, :users)

    add_foreign_key :shopping_cart_items, :shopping_carts unless foreign_key_exists?(:shopping_cart_items, :shopping_carts)

    add_foreign_key :shopping_cart_items, :catalog_products,
                    column: :catalog_product_id,
                    unless: foreign_key_exists?(:shopping_cart_items, :catalog_products)

    # Checkout
    add_foreign_key :checkout_orders, :users unless foreign_key_exists?(:checkout_orders, :users)

    add_foreign_key :checkout_order_items, :checkout_orders,
                    column: :checkout_order_id,
                    unless: foreign_key_exists?(:checkout_order_items, :checkout_orders)

    add_foreign_key :checkout_order_items, :catalog_products,
                    column: :catalog_product_id,
                    unless: foreign_key_exists?(:checkout_order_items, :catalog_products)

    # Catalog
    add_foreign_key :catalog_products, :catalog_categories,
                    column: :catalog_category_id,
                    unless: foreign_key_exists?(:catalog_products, :catalog_categories)

    # Feedback
    add_foreign_key :feedback_reviews, :users unless foreign_key_exists?(:feedback_reviews, :users)

    add_foreign_key :feedback_reviews, :catalog_products,
                    column: :catalog_product_id,
                    unless: foreign_key_exists?(:feedback_reviews, :catalog_products)
  end
end
