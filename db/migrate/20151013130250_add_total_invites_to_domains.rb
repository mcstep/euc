class AddTotalInvitesToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :total_invitations, :integer
  end
end
