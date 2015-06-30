class CreateHorizonAirInstances < ActiveRecord::Migration
  def change
    create_table :horizon_air_instances do |t|
      t.string      :group_name
      t.string      :group_region
      t.string      :instance_url
      t.string      :instance_port
      t.string      :api_key
      t.datetime    :deleted_at,      index: true
      t.timestamps                    null: false
    end
  end
end
