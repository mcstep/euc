class AddProhibitedServicesToUserIntegration < ActiveRecord::Migration
  def change
    add_column :user_integrations, :prohibited_services, :string, null: false, array: true, default: []
  end
end
