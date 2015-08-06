class AddServicesDefaultStatesToProfileIntegrations < ActiveRecord::Migration
  def change
    change_table :profile_integrations do |t|
      t.integer  :office365_default_status
      t.integer  :google_apps_default_status
      t.integer  :airwatch_default_status
      t.integer  :horizon_air_default_status
      t.integer  :horizon_view_default_status
      t.integer  :horizon_rds_default_status
    end
  end
end
