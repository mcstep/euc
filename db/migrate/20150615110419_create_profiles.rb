class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string      :name
      t.string      :home_template
      t.string      :support_email
      t.string      :group_name
      t.boolean     :supports_vidm,       null: false, default: true
      t.datetime    :deleted_at,          index: true
      t.timestamps                        null: false
    end
  end
end
