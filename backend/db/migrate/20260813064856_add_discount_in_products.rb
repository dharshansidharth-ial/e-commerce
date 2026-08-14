class AddDiscountInProducts < ActiveRecord::Migration[8.1]
  def change
        add_column :catalog_products, :discount, :float
  end
end
