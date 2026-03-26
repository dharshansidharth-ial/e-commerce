module Checkout
  class Refund < ApplicationRecord
    self.table_name = "refunds"
    validate :refund_cannot_exceed_payment
    belongs_to :payment,
               class_name: "Checkout::Payment",
               foreign_key: :checkout_payment_id

    def refund_cannot_exceed_payment()
      return unless payment && amount

      if amount > payment.refundable_amount()
        errors.add(:amount, "Exceeds refundable amount!")
      end
    end
  end
end
