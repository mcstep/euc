class AddAirwatchSandboxAdminGroupIdToUserIntegrations < ActiveRecord::Migration
  def change
    add_column :user_integrations, :airwatch_sandbox_admin_group_id, :integer
  end
end
