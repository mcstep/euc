class AddRegCodeIdToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :reg_code_id, :integer
  end
end
