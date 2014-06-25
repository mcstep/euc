class AddTotalInvitationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_invitations, :integer, :default => 5
  end
end
