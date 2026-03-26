class AddPhoneNumberAndAddressToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :checkout_orders, :address, foreign_key: true
    add_reference :checkout_orders, :phone_number, foreign_key: true
  end
end
