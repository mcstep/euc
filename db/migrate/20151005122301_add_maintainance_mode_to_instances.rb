class AddMaintainanceModeToInstances < ActiveRecord::Migration
  def change
    [
      :airwatch_instances, :blue_jeans_instances, :box_instances, 
      :google_apps_instances, :horizon_air_instances, :horizon_instances,
      :office365_instances, :salesforce_instances
    ].each do |service_table|
      add_column service_table, :in_maintainance, :boolean, null: false, default: false
    end
  end
end
