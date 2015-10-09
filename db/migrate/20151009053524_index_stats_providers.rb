class IndexStatsProviders < ActiveRecord::Migration
  def change
    add_index :users, :created_at
    add_index :invitations, :created_at
    add_index :user_authentications, :created_at
  end
end
