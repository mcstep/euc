class AddDisplayNameToInstances < ActiveRecord::Migration
  def change
    add_column :airwatch_instances, :display_name, :string
    add_column :google_apps_instances, :display_name, :string
    add_column :office365_instances, :display_name, :string
    add_column :horizon_instances, :display_name, :string
    add_column :horizon_air_instances, :display_name, :string
    add_column :blue_jeans_instances, :display_name, :string
    add_column :directories, :display_name, :string
  end
end
