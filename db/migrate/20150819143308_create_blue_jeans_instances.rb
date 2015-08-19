class CreateBlueJeansInstances < ActiveRecord::Migration
  def change
    create_table :blue_jeans_instances do |t|
      t.string      :group_name
      t.string      :group_region
      t.string      :grant_type
      t.string      :client_id
      t.string      :client_secret
      t.integer     :enterprise_id
      t.timestamps                  null: false
    end

    change_table :integrations do |t|
      t.belongs_to  :blue_jeans_instance
    end

    change_table :user_integrations do |t|
      t.integer     :blue_jeans_status, null: false, default: 0
    end

    change_table :profile_integrations do |t|
      t.integer     :blue_jeans_default_status
    end
  end
end
