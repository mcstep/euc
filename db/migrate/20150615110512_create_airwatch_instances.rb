class CreateAirwatchInstances < ActiveRecord::Migration
  def change
    create_table :airwatch_instances do |t|
      t.string      :group_name
      t.string      :api_key
      t.string      :host
      t.string      :user
      t.string      :password
      t.string      :parent_group_id
      t.datetime    :deleted_at,      index: true
      t.timestamps                    null: false
    end
  end
end
