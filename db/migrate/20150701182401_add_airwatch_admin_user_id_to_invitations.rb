class AddAirwatchAdminUserIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :airwatch_admin_user_id, :integer
  end
end
