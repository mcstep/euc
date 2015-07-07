class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.belongs_to    :from_user,       index: true
      t.belongs_to    :to_user,         index: true
      t.datetime      :sent_at
      t.integer       :potential_seats
      t.datetime      :deleted_at,      index: true
      t.timestamps                      null: false
    end
  end
end
