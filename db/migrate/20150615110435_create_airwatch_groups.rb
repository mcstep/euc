class CreateAirwatchGroups < ActiveRecord::Migration
  def change
    create_table :airwatch_groups do |t|
      t.string      :text_id
      t.string      :numeric_id
      t.string      :type
      t.belongs_to  :parent,        index: true
      t.datetime    :deleted_at,    index: true
      t.timestamps                  null: false
    end
  end
end
