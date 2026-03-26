class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: {to_table: :checkout_orders}
      t.decimal :amount , precision: 12 , scale: 2 , null: false
      t.string :status

      t.timestamps
    end
  end
end
