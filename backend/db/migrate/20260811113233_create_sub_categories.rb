class CreateSubCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_sub_categories do |t|
      t.string :name
      t.references :catalog_categories , null: false , foreign_key: true

      t.timestamps
    end
  end
end
