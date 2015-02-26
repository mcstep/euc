class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.datetime :expiration_date
      t.string :username
      t.string :company
      t.string :job_title
      t.integer :account_source

      t.timestamps
    end
  end
end
