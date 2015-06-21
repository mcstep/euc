class CreateProfileIntegrations < ActiveRecord::Migration
  def change
    create_table :profile_integrations do |t|
      t.belongs_to    :profile,                 index: true
      t.belongs_to    :integration,             index: true
      t.integer       :authentication_priority, null: false, default: 0
      t.boolean       :allow_sharing,           null: false, default: false
      t.timestamps                              null: false
    end
  end
end
