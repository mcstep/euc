class AddPartnerIdToNominations < ActiveRecord::Migration
  def change
    add_column :nominations, :partner_id, :string
  end
end
