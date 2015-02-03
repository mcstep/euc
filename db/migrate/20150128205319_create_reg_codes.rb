class CreateRegCodes < ActiveRecord::Migration
  def change
    create_table :reg_codes do |t|
      t.string :code
      t.datetime :valid_from
      t.datetime :valid_to
      t.boolean :status
      t.integer :registrations
      t.integer :account_type
      t.integer :account_validity

      t.timestamps
    end
  end
end
