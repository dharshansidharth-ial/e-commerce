class AddImageUrlInCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :catalog_categories, :image_url, :string
  end
end
