class RenameOrderIdInCheckoutPayments < ActiveRecord::Migration[8.1]
  def change
    rename_column :checkout_payments , :order_id , :checkout_order_id
  end
end
