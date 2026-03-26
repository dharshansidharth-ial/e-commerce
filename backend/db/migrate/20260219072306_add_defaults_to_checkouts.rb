class AddDefaultsToCheckouts < ActiveRecord::Migration[8.1]
  def change
    change_column_default :checkout_orders , :status , 0
    change_column_null :checkout_orders , :status , false

    change_column_default :checkout_orders , :total_amount , 0
    change_column_null :checkout_orders , :total_amount , false
  end
end
