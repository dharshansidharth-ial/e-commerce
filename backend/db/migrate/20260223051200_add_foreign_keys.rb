class AddForeignKeys < ActiveRecord::Migration[8.1]
  def change
    unless foreign_key_exists?(:checkout_orders, :users)
      add_foreign_key :checkout_orders, :users
    end

    unless foreign_key_exists?(:payments, :checkout_orders, column: :order_id)
      add_foreign_key :payments, :checkout_orders, column: :order_id
    end

    unless foreign_key_exists?(:refunds, :payments)
      add_foreign_key :refunds, :payments
    end

    unless index_exists?(:checkout_order_items, [:checkout_order_id, :catalog_product_id])
      add_index :checkout_order_items,
                [:checkout_order_id, :catalog_product_id],
                unique: true
    end
  end
end
