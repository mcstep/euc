class CreateOffice365Instances < ActiveRecord::Migration
  def change
    create_table :office365_instances do |t|
      t.string      :group_name
      t.string      :group_region
      t.string      :client_id
      t.string      :client_secret
      t.string      :tenant_id
      t.string      :resource_id
      t.datetime    :deleted_at,      index: true
      t.timestamps                    null: false
    end
  end
end
