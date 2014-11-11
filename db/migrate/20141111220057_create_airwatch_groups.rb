class CreateAirwatchGroups < ActiveRecord::Migration
  def change
    create_table :airwatch_groups do |t|
      t.string :name
      t.string :group_id
      t.integer :group_id_num
      t.integer :parent_id
      t.string :domain
      t.string :group_type

      t.timestamps
    end
  end
end
