class ModifyOrderUserForeignKey < ActiveRecord::Migration[8.1]
  def change
    change_column_null :checkout_orders, :user_id, true

    remove_foreign_key :checkout_orders, :users

    add_foreign_key :checkout_orders, :users,
                    on_delete: :nullify

    add_column :users, :deleted_at, :datetime

    add_index :users,
              "LOWER(email)",
              unique: true,
              where: "deleted_at IS NULL",
              name: "unique_active_users_email"
  end
end
