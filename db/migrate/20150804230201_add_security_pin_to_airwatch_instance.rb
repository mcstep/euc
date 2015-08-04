class AddSecurityPinToAirwatchInstance < ActiveRecord::Migration
  def change
    change_table :airwatch_instances do |t|
      t.string :security_pin
    end
  end
end
