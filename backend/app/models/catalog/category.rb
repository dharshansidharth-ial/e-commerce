module Catalog
  class Category < ApplicationRecord
    # has_many :products,
    #          foreign_key: :catalog_category_id,
    #          class_name: "Catalog::Product",
    #          dependent: :destroy

    has_many :sub_categories,
              foreign_key: :catalog_categories_id,
              class_name: "Catalog::SubCategory"
  end
end
