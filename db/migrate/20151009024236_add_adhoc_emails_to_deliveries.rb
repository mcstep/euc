class AddAdhocEmailsToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :adhoc_emails, :string
  end
end
