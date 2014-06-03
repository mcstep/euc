class AddExpiresAtToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :expires_at, :datetime
  end
end
