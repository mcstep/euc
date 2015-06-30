class CreateOffice365Instances < ActiveRecord::Migration
  def change
    create_table :office365_instances do |t|
      t.string      :group_name
      t.string      :group_region
      t.datetime    :deleted_at,      index: true
      t.timestamps                    null: false
    end
  end
end
