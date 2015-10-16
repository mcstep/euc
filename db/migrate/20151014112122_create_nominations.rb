class CreateNominations < ActiveRecord::Migration
  def change
    create_table :nominations do |t|
      t.belongs_to  :user,          null: false, index: true
      t.string      :company_name,  null: false
      t.string      :domain,        null: false
      t.integer     :status,        null: false, default: 0
      t.integer     :partner_type,  null: false, default: 0
      t.string      :contact_name,  null: false
      t.string      :contact_email, null: false
      t.string      :contact_phone
      t.timestamps                  null: false
    end

    add_column :domains, :nomination_id, :integer
  end
end
