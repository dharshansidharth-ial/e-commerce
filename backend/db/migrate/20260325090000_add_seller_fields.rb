class AddSellerFields < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :seller_status, :integer, default: 0, null: false
    add_reference :catalog_products, :seller, foreign_key: { to_table: :users }
  end
end
