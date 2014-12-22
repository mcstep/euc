desc "This task is called by the Heroku scheduler add-on"

task :send_expiration_reminder => :environment do
  puts "Sends an expiration reminder email 3 days from expiration"
  time = DateTime.now + 72.hour
  expired_accounts= Invitation.where(['expires_at > ? and expires_at < ?', DateTime.now, time])
  puts "There are #{expired_accounts.count} accounts in the system about to expire in 3 days"
  expired_accounts.each do |account|
    puts "#{account.recipient_firstname}'s account with email #{account.recipient_email} expires on #{account.expires_at}"
    if !account.acc_expiration_reminder_email?
      AccountExpireReminderEmailWorker.perform_async(account.id)
    end
  end
end

task :send_expiration_email => :environment do
  puts "Sends an expiration email 24 hours after expiration"
  time = DateTime.now - 24.hour #24 hour grace period
  expired_accounts = Invitation.where(['expires_at < ?', time]).limit(25)
  puts "There are #{expired_accounts.count} expired accounts in the system"
  expired_accounts.each do |account|
    puts "#{account.recipient_firstname}'s account with email #{account.recipient_email} expired on #{account.expires_at}"
    #Remove the AD account
    account_removed = false
    begin
      response = RestClient.post(url="#{ENV['API_HOST']}/unregister",payload={:username => account.recipient_username}, headers= {:token => ENV["API_KEY"]})
      puts "Got response #{response} for account deletion"
      if response.code == 200
        account.destroy
        @user_rec_for_invite = User.find_by_email(account.recipient_email)
        @user_rec_for_invite.destroy unless @user_rec_for_invite.nil?
        account_removed = true
        AccountExpireEmailWorker.perform_async(account.id)
        # Remove AirWatch account if the user is already enrolled
        if !account.airwatch_user_id.nil?
          AirwatchUnprovisionWorker.perform_async(account.id)
        end
      end
    rescue RestClient::Exception => e
      puts e
    rescue Exception => e
      puts e
    end

    #Update the invitation limit
    @user = account.sender
    if !@user.nil?
     @user.invitation_limit += 1
     #new invitation limit model
     @user.invitations_used -= 1
     @user.save!
    end
  end
end
