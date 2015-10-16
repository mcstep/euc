class AddDesiredPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :desired_password, :string
  end
end
