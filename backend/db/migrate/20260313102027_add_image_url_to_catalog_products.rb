class AddImageUrlToCatalogProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :catalog_products, :image_url, :string
  end
end
