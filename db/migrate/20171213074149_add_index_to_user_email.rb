class AddIndexToUserEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true#add index to email in user table
  end
end
