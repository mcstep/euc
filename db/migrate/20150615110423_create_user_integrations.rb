class CreateUserIntegrations < ActiveRecord::Migration
  def change
    create_table :user_integrations do |t|
      t.belongs_to  :user,                      index: true
      t.belongs_to  :integration,               index: true
      t.integer     :authentication_priority,   null: false, default: 0
      t.string      :directory_username
      t.date        :directory_expiration_date, null: false
      t.integer     :directory_status
      t.integer     :horizon_air_status,        null: false, default: 0
      t.integer     :horizon_workspace_status,  null: false, default: 0
      t.integer     :horizon_rds_status,        null: false, default: 0
      t.integer     :horizon_view_status,       null: false, default: 0
      t.integer     :airwatch_status,           null: false, default: 0
      t.integer     :office365_status,          null: false, default: 0
      t.integer     :google_apps_status,        null: false, default: 0
      t.belongs_to  :airwatch_user,             index: true
      t.belongs_to  :airwatch_group,            index: true
      t.datetime    :deleted_at,                index: true
      t.timestamps                              null: false
    end
  end
end
