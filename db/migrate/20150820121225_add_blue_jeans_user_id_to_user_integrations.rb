class AddBlueJeansUserIdToUserIntegrations < ActiveRecord::Migration
  def change
    change_table :user_integrations do |t|
      t.integer :blue_jeans_user_id
    end
  end
end
