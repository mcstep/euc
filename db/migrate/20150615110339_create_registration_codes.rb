class CreateRegistrationCodes < ActiveRecord::Migration
  def change
    create_table :registration_codes do |t|
      t.integer     :user_role,           null: false, default: 0
      t.integer     :user_validity,       null: false, default: 30
      t.string      :code,                null: false
      t.integer     :total_registrations, null: false, default: 0
      t.integer     :registrations_used,  null: false, default: 0
      t.date        :valid_from
      t.date        :valid_to
      t.datetime    :deleted_at,          index: true
      t.timestamps                        null: false
    end
  end
end
