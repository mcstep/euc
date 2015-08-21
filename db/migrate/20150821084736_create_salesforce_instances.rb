class CreateSalesforceInstances < ActiveRecord::Migration
  def change
    create_table :salesforce_instances do |t|
      t.string      :display_name
      t.string      :group_name
      t.string      :group_region
      t.string      :username
      t.string      :password
      t.string      :security_token
      t.string      :client_id
      t.string      :client_secret
      t.string      :time_zone
      t.string      :common_locale
      t.string      :language_locale
      t.string      :email_encoding
      t.string      :profile_id
      t.timestamps                    null: false
    end

    change_table :integrations do |t|
      t.belongs_to  :salesforce_instance
    end

    change_table :user_integrations do |t|
      t.integer     :salesforce_status, null: false, default: 0
    end

    change_table :profile_integrations do |t|
      t.integer     :salesforce_default_status
    end

    change_table :user_integrations do |t|
      t.integer     :salesforce_user_id
    end
  end
end
