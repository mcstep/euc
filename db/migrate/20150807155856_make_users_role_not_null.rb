class MakeUsersRoleNotNull < ActiveRecord::Migration
  def change
    User.where(role: nil).update_all(role: 0)

    change_column :users, :role, :integer, null: false, default: 0
  end
end
