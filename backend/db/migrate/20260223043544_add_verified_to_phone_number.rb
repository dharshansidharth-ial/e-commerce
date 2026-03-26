class AddVerifiedToPhoneNumber < ActiveRecord::Migration[8.1]
  def change
    add_column :phone_numbers , :verified , :boolean , default: false , null: false
  end
end
