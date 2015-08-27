class AddDeletedAtToBlueJeansAndSalesforce < ActiveRecord::Migration
  def change
    add_column :blue_jeans_instances, :deleted_at, :datetime
    add_column :salesforce_instances, :deleted_at, :datetime
  end
end
