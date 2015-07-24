class CreateAirwatchGroups < ActiveRecord::Migration
  def change
    create_table :airwatch_groups do |t|
      t.belongs_to  :airwatch_instance
      t.belongs_to  :company
      t.string      :text_id
      t.string      :numeric_id
      t.string      :kind
      t.datetime    :deleted_at,    index: true
      t.timestamps                  null: false
    end
  end
end
