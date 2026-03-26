class ChangePhoneForeignKeyOnCheckoutOrders < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :checkout_orders , :phone_numbers

    add_foreign_key :checkout_orders , :phone_numbers , on_delete: :nullify

    change_column_null :checkout_orders , :phone_number_id , true
  end
end
