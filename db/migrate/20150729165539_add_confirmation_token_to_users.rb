class AddConfirmationTokenToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :verification_token
    end

    User.update_all(status: 0)
    change_column :users, :status, :integer, null: false, default: 0
  end

  def down
    remove_column :users, :verification_token
  end
end
