class CreateDirectoryProlongations < ActiveRecord::Migration
  def change
    create_table :directory_prolongations do |t|
      t.belongs_to    :user_integration,    index: true
      t.belongs_to    :user,                index: true
      t.string        :reason
      t.date          :expiration_date_old
      t.date          :expiration_date_new
      t.timestamps                          null: false
    end
  end
end
