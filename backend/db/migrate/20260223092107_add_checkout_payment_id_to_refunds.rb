class AddCheckoutPaymentIdToRefunds < ActiveRecord::Migration[8.1]
  def change
    # Remove old foreign key first (if exists)
    if foreign_key_exists?(:refunds, :payments)
      remove_foreign_key :refunds, :payments
    end

    # Rename column only if it still exists
    if column_exists?(:refunds, :payment_id)
      rename_column :refunds, :payment_id, :checkout_payment_id
    end

    # Add new foreign key safely
    unless foreign_key_exists?(:refunds, :checkout_payments)
      add_foreign_key :refunds,
                      :checkout_payments,
                      column: :checkout_payment_id
    end
  end
end
