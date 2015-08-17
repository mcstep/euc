class AddLicenseNameToOffice365Instance < ActiveRecord::Migration
  def change
    change_table :office365_instances do |t|
      t.string :license_name
    end
  end
end
