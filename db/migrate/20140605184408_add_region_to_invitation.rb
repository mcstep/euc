class AddRegionToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :region, :string
  end
end
