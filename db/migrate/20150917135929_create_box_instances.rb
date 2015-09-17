class CreateBoxInstances < ActiveRecord::Migration
  def change
    create_table :box_instances do |t|
      t.string      :display_name
      t.string      :group_name
      t.string      :group_region
      t.string      :token_retriever_url
      t.string      :username
      t.string      :password
      t.string      :client_id
      t.string      :client_secret
      t.string      :access_token
      t.string      :refresh_token
      t.timestamps                    null: false
    end

    change_table :integrations do |t|
      t.belongs_to  :box_instance
    end

    change_table :user_integrations do |t|
      t.integer     :box_status, null: false, default: 0
      t.integer     :box_user_id
    end

    change_table :profile_integrations do |t|
      t.integer     :box_default_status
    end
  end
end
