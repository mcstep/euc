desc "This task will send a mass email to everyone registered on the dem portal informing them of the new upgrades"

task :mass_email_for_all_registered_users => :environment do
  puts "Sends a mass email to everyone registered on the dem portal informing them of the new upgrade"
  invitations = Invitation.all
  invitations.each do |inv|
    puts "Working on invite - #{inv.recipient_username}"
    if inv.expires_at > DateTime.now
      UpgradeMassEmail.perform_async(inv.id)
    end
  end
end