class AddInvitationIdIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :invitation_id
  end
end
