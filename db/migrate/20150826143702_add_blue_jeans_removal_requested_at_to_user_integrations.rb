class AddBlueJeansRemovalRequestedAtToUserIntegrations < ActiveRecord::Migration
  def change
    change_table :user_integrations do |t|
      t.datetime :blue_jeans_removal_requested_at
    end
  end
end
