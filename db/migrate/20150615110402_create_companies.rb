class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string      :name
      t.datetime    :deleted_at,  index: true
      t.timestamps                null: false
    end
  end
end
