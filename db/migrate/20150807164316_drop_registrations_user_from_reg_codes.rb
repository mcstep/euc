class DropRegistrationsUserFromRegCodes < ActiveRecord::Migration
  def change
    remove_column :registration_codes, :registrations_used, :integer
  end
end
