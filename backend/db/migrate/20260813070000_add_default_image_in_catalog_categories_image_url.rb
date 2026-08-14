class AddDefaultImageInCatalogCategoriesImageUrl < ActiveRecord::Migration[8.1]
  DEFAULT_IMAGE_URL = "assets/images/categories/default.svg"

  def up
    change_column_default :catalog_categories, :image_url, from: nil, to: DEFAULT_IMAGE_URL
    execute <<~SQL
      UPDATE catalog_categories SET image_url = #{quote(DEFAULT_IMAGE_URL)}
      WHERE image_url IS NULL OR image_url = ''
    SQL
  end

  def down
    change_column_default :catalog_categories, :image_url, from: DEFAULT_IMAGE_URL, to: nil
  end
end
