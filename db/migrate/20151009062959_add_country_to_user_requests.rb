class AddCountryToUserRequests < ActiveRecord::Migration
  def change
    add_column :user_requests, :country, :string, index: true
  end
end
