class AccountExpireReminderEmailWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.find_by_id(invitation_id)	 
    puts "Sending account expiry reminder email to recipient: #{@invitation.recipient_email}"
    WelcomeUserMailer.account_expiry_reminder_email(@invitation).deliver
    @invitation.acc_expiration_reminder_email = true
    @invitation.save!
    puts "Account expiry reminder email sent successfully"
  end
end
