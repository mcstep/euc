class CreateHorizonInstances < ActiveRecord::Migration
  def change
    create_table :horizon_instances do |t|
      t.string      :rds_group_name
      t.string      :workspace_group_name
      t.string      :view_group_name
      t.string      :group_region
      t.string      :api_host
      t.string      :api_port
      t.string      :api_key
      t.datetime    :deleted_at,          index: true
      t.timestamps                        null: false
    end
  end
end
