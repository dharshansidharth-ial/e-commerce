module Checkout
  class Payment < ApplicationRecord
    belongs_to :order,
               class_name: "Checkout::Order",
               foreign_key: :checkout_order_id

    has_many :refunds,
             class_name: "Refund",
             foreign_key: "checkout_payment_id",
             dependent: :destroy

    validates :amount, numericality: { greater_than: 0 }

    def refundable_amount()
      amount - refunds.sum(:amount)
    end
  end
end
