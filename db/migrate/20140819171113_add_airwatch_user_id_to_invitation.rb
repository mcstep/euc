class AddAirwatchUserIdToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :airwatch_user_id, :integer
  end
end
