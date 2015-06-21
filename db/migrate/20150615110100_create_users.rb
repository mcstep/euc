class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.belongs_to        :company,                   index: true
      t.belongs_to        :profile,                   index: true
      t.belongs_to        :registration_code,         index: true
      t.string            :email,                     null: false, index: true, unique: true
      t.string            :first_name
      t.string            :last_name
      t.string            :avatar
      t.string            :country_code
      t.string            :phone
      t.integer           :role
      t.integer           :status
      t.string            :job_title
      t.integer           :invitations_used,          null: false, default: 0
      t.integer           :total_invitations,         null: false, default: 5
      t.string            :home_region
      t.date              :airwatch_eula_accept_date
      t.datetime          :deleted_at,                index: true
      t.timestamps                                    null: false
    end
  end
end
