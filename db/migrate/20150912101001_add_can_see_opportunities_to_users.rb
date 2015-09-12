class AddCanSeeOpportunitiesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_see_opportunities, :boolean, null: false, default: false
  end
end
