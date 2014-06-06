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
      #response = RestClient.post 'http://75.126.198.236:8080/signup', :fname => @invitation.recipient_firstname, :lname => @invitation.recipient_lastname, :uname => 'demo.user', :org => @invitation.recipient_company, :email => @invitation.recipient_email, :title => @invitation.recipient_title, :expires_at => ((@invitation.expires_at.to_i)*1000), :region => region
      response = RestClient.post(url='http://75.126.198.236:8080/signup', payload ={:fname => @invitation.recipient_firstname, :lname => @invitation.recipient_lastname, :uname => 'demo.user', :org => @invitation.recipient_company, :email => @invitation.recipient_email, :title => @invitation.recipient_title, :expires_at => ((@invitation.expires_at.to_i)*1000), :region => region}, headers={:token => ENV["API_KEY"]})

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
      url = "http://75.126.198.236:8080/createdir"
      response = RestClient.post url, :username => @invitation.recipient_username, :region => region
      puts response.body
    rescue => e
      puts e
    end
    puts "Created user profile directory successfully"

    puts "Calling sync service.."
    begin
      url = "http://75.126.198.236:8080/sync/#{region}"
      response = RestClient.post url, :uname => 'demo.user'
      puts response.body
    rescue => e
      puts e
    end
    puts "Sync success"
  end
end
