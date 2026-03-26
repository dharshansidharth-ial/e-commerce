class PhoneNumber < ApplicationRecord
  belongs_to :user,
             foreign_key: :user_id

  has_one :order,
          class_name: "Checkout::Order",
          foreign_key: "phone_number_id"
end
