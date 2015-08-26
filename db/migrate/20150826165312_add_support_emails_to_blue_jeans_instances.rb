class AddSupportEmailsToBlueJeansInstances < ActiveRecord::Migration
  def change
    add_column :blue_jeans_instances, :support_emails, :string
  end
end
