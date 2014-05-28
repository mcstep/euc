class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :sender_id
      t.string :recipient_email
      t.string :token
      t.string :recipient_username
      t.string :recipient_firstname
      t.string :recipient_lastname
      t.string :recipient_title
      t.string :recipient_company

      t.timestamps
    end
  end
end
