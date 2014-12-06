desc "This task enables/disables the airwatch and google apps trial for all portal users except those who have  already activated their account"

task :enable_airwatch_for_all_users => :environment do
  puts "Enables airwatch for everyone who hasn't activated their airwatch account already"
  invitations = Invitation.all
  invitations.each do |inv|
    puts "Working on invite - #{inv.recipient_username}"
    if inv.eula_accept_date.nil? and inv.airwatch_user_id.nil?
      puts "Will enable Airwatch for invite - #{inv.recipient_username}"      
      begin
        inv.airwatch_trial = true
        inv.google_apps_trial = true
        inv.save!
      rescue Exception => e
        puts "Issue enabling airwatch trial for invite #{inv.recipient_username}: #{e}"
      end
    end
  end
end

task :disable_airwatch_for_all_users => :environment do
  puts "Disables airwatch for everyone who hasn't activated their airwatch account already"
  invitations = Invitation.all
  invitations.each do |inv|
    puts "Working on invite - #{inv.recipient_username}"
    if inv.eula_accept_date.nil? and inv.airwatch_user_id.nil?
      puts "Will disable Airwatch for invite - #{inv.recipient_username}"      
      begin
        inv.airwatch_trial = nil
        inv.google_apps_trial = nil
        inv.save!
      rescue Exception => e
        puts "Issue disabling airwatch trial for invite #{inv.recipient_username}: #{e}"
      end
    end
  end
end
