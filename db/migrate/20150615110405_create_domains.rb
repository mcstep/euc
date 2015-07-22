class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.belongs_to    :company,     index: true
      t.belongs_to    :profile,     index: true
      t.string        :name
      t.integer       :status,      null: false, default: 0
      t.integer       :limit
      t.integer       :user_role,   null: false, default: 0
      t.datetime      :deleted_at,  index: true
      t.timestamps                  null: false
    end
  end
end
