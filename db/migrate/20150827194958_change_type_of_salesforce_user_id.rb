class ChangeTypeOfSalesforceUserId < ActiveRecord::Migration
  def change
    change_column :user_integrations, :salesforce_user_id, :string
  end
end
