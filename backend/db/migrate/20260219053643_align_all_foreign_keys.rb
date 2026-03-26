class AlignAllForeignKeys < ActiveRecord::Migration[8.0]
  def change
    # ============================
    # CATALOG PRODUCTS
    # ============================

    unless column_exists?(:catalog_products, :catalog_category_id)
      add_column :catalog_products, :catalog_category_id, :bigint, null: false
    end

    unless foreign_key_exists?(:catalog_products, :catalog_categories, column: :catalog_category_id)
      add_foreign_key :catalog_products,
                      :catalog_categories,
                      column: :catalog_category_id
    end

    add_index :catalog_products, :catalog_category_id unless index_exists?(:catalog_products, :catalog_category_id)


    # ============================
    # SHOPPING CARTS
    # ============================

    unless foreign_key_exists?(:shopping_carts, :users)
      add_foreign_key :shopping_carts, :users
    end


    # ============================
    # SHOPPING CART ITEMS
    # ============================

    unless foreign_key_exists?(:shopping_cart_items, :shopping_carts)
      add_foreign_key :shopping_cart_items, :shopping_carts
    end

    unless foreign_key_exists?(:shopping_cart_items, :catalog_products, column: :catalog_product_id)
      add_foreign_key :shopping_cart_items,
                      :catalog_products,
                      column: :catalog_product_id
    end


    # ============================
    # CHECKOUT ORDERS
    # ============================

    unless foreign_key_exists?(:checkout_orders, :users)
      add_foreign_key :checkout_orders, :users
    end


    # ============================
    # CHECKOUT ORDER ITEMS
    # ============================

    unless foreign_key_exists?(:checkout_order_items, :checkout_orders, column: :checkout_order_id)
      add_foreign_key :checkout_order_items,
                      :checkout_orders,
                      column: :checkout_order_id
    end

    unless foreign_key_exists?(:checkout_order_items, :catalog_products, column: :catalog_product_id)
      add_foreign_key :checkout_order_items,
                      :catalog_products,
                      column: :catalog_product_id
    end


    # ============================
    # FEEDBACK REVIEWS
    # ============================

    unless foreign_key_exists?(:feedback_reviews, :users)
      add_foreign_key :feedback_reviews, :users
    end

    unless foreign_key_exists?(:feedback_reviews, :catalog_products, column: :catalog_product_id)
      add_foreign_key :feedback_reviews,
                      :catalog_products,
                      column: :catalog_product_id
    end
  end
end
