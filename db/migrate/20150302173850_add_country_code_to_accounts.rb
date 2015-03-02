class AddCountryCodeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :country_code, :string
  end
end
