class ModifyUsers < ActiveRecord::Migration[8.1]
  def change
    # Make columns NOT NULL
    change_column_null :users, :email, false
    change_column_null :users, :password_digest, false

    # Add unique index on email
    add_index :users, :email, unique: true
  end
end
