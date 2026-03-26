class AddActiveAndTotalToCart < ActiveRecord::Migration[8.1]
  def change
    add_column :shopping_carts , :status , :string , default: "active" , null: false
    add_column :shopping_carts, :total , :decimal , default: 0 , null: false , precision: 10 , scale: 2

  end
end
