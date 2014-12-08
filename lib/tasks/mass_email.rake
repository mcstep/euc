desc "This task will send a mass email to everyone registered on the dem portal informing them of the new upgrades"

task :mass_email_for_all_registered_users => :environment do
  puts "Sends a mass email to everyone registered on the dem portal informing them of the new upgrade"
  invitations = Invitation.all
  invitations.each do |inv|
    puts "Working on invite - #{inv.recipient_username}"
    if inv.expires_at > DateTime.now
      puts "Will send upgrade email to - #{inv.recipient_email}"      
      begin
        WelcomeUserMailer.portal_upgrades_email(inv).deliver
      rescue Exception => e
        puts "Issue sending portal upgrades email to invite #{inv.recipient_email}: #{e}"
      end
      puts "Portal upgrades mass email sent successfully"
    end
  end
end