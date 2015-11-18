class IndexInvitationsByCrmKind < ActiveRecord::Migration
  def change
    add_index :invitations, :crm_kind
  end
end
