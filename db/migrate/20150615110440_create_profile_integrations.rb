class CreateProfileIntegrations < ActiveRecord::Migration
  def change
    create_table :profile_integrations do |t|
      t.belongs_to    :profile,                 index: true
      t.belongs_to    :integration,             index: true
      t.integer       :authentication_priority, null: false, default: 100
      t.boolean       :allow_sharing,           null: false, default: false
      t.timestamps                              null: false
    end

    add_index :profile_integrations, [:profile_id, :integration_id], unique: true
  end
end
