class AddHomeRegionToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :home_region, :string
  end
end
