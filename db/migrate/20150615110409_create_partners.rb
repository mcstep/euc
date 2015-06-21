class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.belongs_to  :company,           index: true
      t.integer     :vmware_partner_id
      t.string      :contact_name
      t.string      :contact_email
      t.string      :contact_phone
      t.datetime    :deleted_at,        index: true
      t.timestamps                      null: false
    end
  end
end
