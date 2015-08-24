class AddCanEditServicesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_edit_services, :boolean, null: false, default: false
  end
end
