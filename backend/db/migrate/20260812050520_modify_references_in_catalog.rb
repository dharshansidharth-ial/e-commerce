class ModifyReferencesInCatalog < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :catalog_products , column: :catalog_category_id
    rename_column :catalog_products , :catalog_category_id , :catalog_sub_categories_id
    
    add_foreign_key :catalog_products , :catalog_sub_categories , column: :catalog_sub_categories_id
    # add_foreign_key :catalog_sub_categories, :catalog_categories , column: :catalog_categories_id
  end
end
