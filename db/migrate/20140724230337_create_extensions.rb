class CreateExtensions < ActiveRecord::Migration
  def change
    create_table :extensions do |t|
      t.integer :extended_by
      t.integer :recipient
      t.string :reason
      t.datetime :original_expires_at
      t.datetime :revised_expires_at
    end
  end
end
