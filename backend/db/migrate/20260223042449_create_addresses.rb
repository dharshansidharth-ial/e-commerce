class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :line1
      t.string :city
      t.string :country
      t.boolean :default , default: false

      t.timestamps
    end
  end
end
