class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.belongs_to  :company,     index: true
      t.string      :name
      t.datetime    :deleted_at,  index: true
      t.timestamps                null: false
    end
  end
end
