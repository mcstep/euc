class MoveAirwatchSettingsFromProfilesToInstances1 < ActiveRecord::Migration
  def change
    change_table :airwatch_instances do |t|
      t.boolean :use_admin, null: false, default: false
      t.boolean :use_groups, null: false, default: true
    end
  end
end
