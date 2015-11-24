class MakeUsernameNotNull < ActiveRecord::Migration
  def change
    UserIntegration.where(username: nil).update_all(username: '')
    change_column :user_integrations, :username, :string, null: false, defalut: ''
  end
end
