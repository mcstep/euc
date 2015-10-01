class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.belongs_to  :profile
      t.string      :from_email,    null: false
      t.string      :subject,       null: false
      t.text        :body,          null: false
      t.datetime    :send_at
      t.integer     :status,        null: false, default: 0
      t.text        :response
      t.timestamps                  null: false
    end
  end
end
