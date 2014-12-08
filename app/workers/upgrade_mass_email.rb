class UpgradeMassEmail
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.find_by_id(invitation_id)	 
    puts "Will send upgrade email to - #{@invitation.recipient_email}"      
    begin
    	WelcomeUserMailer.portal_upgrades_email(@invitation).deliver
    rescue Exception => e
        puts "Issue sending portal upgrades email to invite #{@invitation.recipient_email}: #{e}"
    end
    puts "Portal upgrades mass email sent successfully"
  end
end
