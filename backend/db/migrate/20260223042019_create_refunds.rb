class CreateRefunds < ActiveRecord::Migration[8.1]
  def change
    create_table :refunds do |t|
      t.references :payment, null: false, foreign_key: true
      t.decimal :amount , precision: 12 , scale: 2 , null: false
      t.string :reason

      t.timestamps
    end
  end
end
