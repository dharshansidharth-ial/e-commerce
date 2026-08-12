class RemoveForeignKeyFromCatalogProduct < ActiveRecord::Migration[8.1]
  def change
    # Pass the target table name (:catalog_sub_categories) as the second argument
    remove_foreign_key :catalog_products, :catalog_categories, column: :catalog_sub_categories_id
  end
end
