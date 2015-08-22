class RelinkAirwatchGroups < ActiveRecord::Migration
  def change
    remove_column :airwatch_groups, :company_id, :integer
  end
end
