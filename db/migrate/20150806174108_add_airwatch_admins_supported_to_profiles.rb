class AddAirwatchAdminsSupportedToProfiles < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.boolean :airwatch_admins_supported, null: false, default: false
    end
  end
end
