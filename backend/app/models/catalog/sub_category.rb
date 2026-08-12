module Catalog
  class SubCategory < ApplicationRecord
    belongs_to :catalog_category,
                foreign_key: :catalog_category_id,
                class_name: "Catalog::Category"

    has_many :products,
              foreign_key: :catalog_category_id,
              class_name: "Catalog::Product",
              dependent: :destroy
  end
end