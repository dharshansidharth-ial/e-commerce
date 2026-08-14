module Catalog
  class SubCategory < ApplicationRecord
    belongs_to :catalog_category,
                foreign_key: :catalog_categories_id,
                class_name: "Catalog::Category"

    has_many :products,
              foreign_key: :catalog_sub_categories_id,
              class_name: "Catalog::Product",
              dependent: :destroy
  end
end