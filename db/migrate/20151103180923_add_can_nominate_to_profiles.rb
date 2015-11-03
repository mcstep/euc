class AddCanNominateToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :can_nominate, :boolean, null: false, default: false
  end
end
