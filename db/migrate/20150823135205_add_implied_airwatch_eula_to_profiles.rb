class AddImpliedAirwatchEulaToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :implied_airwatch_eula, :boolean, null: false, default: false
  end
end
