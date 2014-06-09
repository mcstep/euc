class SignupWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.find_by_id(invitation_id)
    puts "Will start working on Invitation ID#{invitation_id} for Recipient #{@invitation.recipient_email}"
    
    region = "dldc"
    if !@invitation.region.nil?
      region = @invitation.region.downcase
    end

    account_created = false
    begin
      response = RestClient.post(url='http://75.126.198.236:8080/signup', payload ={:fname => @invitation.recipient_firstname, :lname => @invitation.recipient_lastname, :username => @invitation.recipient_username, :org => @invitation.recipient_company, :email => @invitation.recipient_email, :title => @invitation.recipient_title, :expires_at => ((@invitation.expires_at.to_i)*1000), :region => region}, headers={:token => ENV["API_KEY"]})

      if response.code == 200
        json_body = JSON.parse response
        @invitation.recipient_username = json_body['username']
        @invitation.save!
        account_created = true
      end
    rescue => e
      #@invitation.errors[:base] << "Sorry! Could not contact the AD Server at this time. Please try again later!"
      logger.error "error contacting AD server"
      puts e
    end

    puts "Done creating account. Response from AD #{json_body}"

    puts "Sending email...."
    WelcomeUserMailer.welcome_email(@invitation,json_body['password']).deliver
    puts "Email sent successfully"

    puts "Creating user profile directory.."
    begin
      create_dir_url = "http://75.126.198.236:8080/createdir"
      response = RestClient.post(url=create_dir_url,payload={:username => @invitation.recipient_username, :region => region}, headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    puts "Created user profile directory successfully"

    puts "Calling sync service for home region.."
    begin
      home_sync_url = "http://75.126.198.236:8080/sync/#{region}"
      response = RestClient.post(url=home_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    puts "Sync success"

    puts "Calling sync service for remaining regions.."
    rem_regions = ['amer', 'dldc', 'emea', 'apac'] - ["#{region}"]
    rem_regions.each do |sync_reg|
      begin
        sync_url = "http://75.126.198.236:8080/sync/#{sync_reg}"
        response = RestClient.post(url=sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
    end
    puts "Sync success"
  end
end
