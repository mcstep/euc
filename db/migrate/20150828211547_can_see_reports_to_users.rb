class CanSeeReportsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_see_reports, :boolean, null: false, default: false
  end
end
