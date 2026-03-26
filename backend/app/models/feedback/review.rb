module Feedback
  class Review < ApplicationRecord
    belongs_to :user,
    foreign_key: :user_id

    belongs_to :product,
    foreign_key: :catalog_product_id,
    class_name: "Catalog::Product"
  end
end
