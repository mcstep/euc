class AccountExtensionEmailWorker
  include Sidekiq::Worker

  def perform(invitation_id, extension_id)
    @invitation = Invitation.find_by_id(invitation_id)	 
    @extension = Extension.find_by_id(extension_id)	 
    puts "Sending account extension email to recipient: #{@invitation.recipient_email}"
    WelcomeUserMailer.account_extension_email(@invitation, @extension).deliver
    puts "Account extension email sent successfully"
  end
end
