class ChangeAddressForeignKeyOnCheckoutOrders < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :checkout_orders , :addresses

    add_foreign_key :checkout_orders , :addresses , on_delete: :nullify

    change_column_null :checkout_orders , :address_id , true
  end
end
