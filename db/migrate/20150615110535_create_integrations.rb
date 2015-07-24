class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.string      :name
      t.string      :domain
      t.belongs_to  :directory,                   index: true
      t.belongs_to  :office365_instance,          index: true
      t.belongs_to  :google_apps_instance,        index: true
      t.belongs_to  :airwatch_instance,           index: true
      t.belongs_to  :horizon_air_instance,        index: true
      t.belongs_to  :horizon_view_instance,       index: true
      t.belongs_to  :horizon_rds_instance,        index: true
      t.datetime    :deleted_at,                  index: true
      t.timestamps                                null: false
    end
  end
end
