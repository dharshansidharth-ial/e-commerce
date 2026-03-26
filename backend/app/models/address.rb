class Address < ApplicationRecord
  belongs_to :user

  has_one :order,
          class_name: "Checkout::Order",
          foreign_key: "address_id"
end
