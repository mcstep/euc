class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string      :first_name
      t.string      :last_name
      t.string      :email
      t.datetime    :expiration_date
      t.string      :username
      t.string      :company
      t.string      :job_title
      t.integer     :account_source
      t.datetime    :created_at
      t.datetime    :updated_at
      t.datetime    :deleted_at,        index: true
      t.string      :home_region
      t.string      :uuid
      t.string      :country_code
    end
  end
end
