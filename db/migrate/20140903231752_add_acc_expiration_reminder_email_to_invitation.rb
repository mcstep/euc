class AddAccExpirationReminderEmailToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :acc_expiration_reminder_email, :boolean
  end
end
