class AddDefaultImageInCatalogProductsImageUrl < ActiveRecord::Migration[8.1]
  DEFAULT_IMAGE_URL = "assets/images/no_image.png"

  def up
    change_column_default :catalog_products, :image_url, from: nil, to: DEFAULT_IMAGE_URL
    execute <<~SQL
      UPDATE catalog_products SET image_url = #{quote(DEFAULT_IMAGE_URL)}
      WHERE image_url IS NULL OR image_url = ''
    SQL
  end

  def down
    change_column_default :catalog_products, :image_url, from: DEFAULT_IMAGE_URL, to: nil
  end
end
