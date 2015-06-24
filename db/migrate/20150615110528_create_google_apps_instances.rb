class CreateGoogleAppsInstances < ActiveRecord::Migration
  def change
    create_table :google_apps_instances do |t|
      t.string      :group_name
      t.text        :key_base64
      t.string      :key_password
      t.string      :initial_password
      t.string      :service_account
      t.string      :act_on_behalf
      t.datetime    :deleted_at,        index: true
      t.timestamps                      null: false
    end
  end
end
