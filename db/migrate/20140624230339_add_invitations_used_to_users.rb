class AddInvitationsUsedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invitations_used, :integer, :default => 0
  end
end
