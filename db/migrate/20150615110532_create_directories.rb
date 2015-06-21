class CreateDirectories < ActiveRecord::Migration
  def change
    create_table :directories do |t|
      t.string      :host
      t.string      :port
      t.string      :api_key
      t.datetime    :deleted_at,  index: true
      t.timestamps                null: false
    end
  end
end
