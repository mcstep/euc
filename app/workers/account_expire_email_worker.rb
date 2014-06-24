class AccountExpireEmailWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.with_deleted.find_by_id(invitation_id)	 
    puts "Sending account expiry email to recipient:"
    WelcomeUserMailer.account_expiry_email(@invitation).deliver
    puts "Account expiry email sent successfully"
  end
end
