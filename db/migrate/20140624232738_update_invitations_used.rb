class UpdateInvitationsUsed < ActiveRecord::Migration
  def up
    execute "update users set invitations_used = total_invitations - invitation_limit"
  end
 
  def down
  end
end
