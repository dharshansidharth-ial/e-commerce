module Checkout
  class Order < ApplicationRecord
    # attribute :status , :integer , default: 0
    # attribute :total_amount , :decimal , default: 0

    before_validation :set_defaults
    validate :user_must_be_allowed
    validate :cannot_pay_twice

    belongs_to :user,
               class_name: "User",
               foreign_key: :user_id

    belongs_to :phone_number,
               optional: true,
               class_name: "PhoneNumber",
               foreign_key: "phone_number_id"

    belongs_to :address,
               optional: true,
               class_name: "Address",
               foreign_key: "address_id"

    has_many :order_items,
             class_name: "Checkout::OrderItem",
             foreign_key: :checkout_order_id,
             dependent: :destroy

    has_one :payment,
             class_name: "Checkout::Payment",
             foreign_key: :checkout_order_id,
             dependent: :nullify

    has_many :products,
             through: :order_items,
             source: :product

  enum :status, {
    pending: 0,
    paid: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4,
  }

    def recalculate_total!()
      total = order_items.sum("price * quantity")
      update_column(:total_amount, total)
    end

    def complete_order!()
      transaction do
        order_items.each do |item|
          product = item.product
          raise "Out of stock!" if product.stock < item.quantity
          product.update!(stock: product.stock - item.quantity)
        end
      end
      update!(status: "paid")
    end

    private

    def set_defaults()
      self.status = self.status || 0
      self.total_amount = self.total_amount || 0
    end

    def user_must_be_allowed()
      unless user&.can_shop?
        errors.add(:base, "User not allowed to place orders!")
      end
    end

    def cannot_pay_twice()
      if status_in_database == "paid" && paid?
        errors.add(:base, "Order already paid!")
      end
    end
  end
end
