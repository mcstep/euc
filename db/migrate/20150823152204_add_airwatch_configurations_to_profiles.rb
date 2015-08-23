class AddAirwatchConfigurationsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :airwatch_create_groups, :boolean, null: false, default: true
    add_column :profiles, :airwatch_notify_by_email, :boolean, null: false, default: true
  end
end
