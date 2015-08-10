class AddProfileIdToRegCodes < ActiveRecord::Migration
  def change
    change_table :registration_codes do |t|
      t.integer     :profile_id
    end
  end
end
