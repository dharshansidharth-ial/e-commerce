class RenamePaymentToCheckoutPayment < ActiveRecord::Migration[8.1]
  def change
    rename_table :payments , :checkout_payments
  end
end
