module Catalog
  class Category < ApplicationRecord
    has_many :products,
             foreign_key: :catalog_category_id,
             class_name: "Catalog::Product",
             dependent: :destroy
  end
end
