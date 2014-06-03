class SignupWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.find_by_id(invitation_id)
    puts "Will start working on Invitation ID#{invitation_id} for Recipient #{@invitation.recipient_email}"

    account_created = false
    begin
      response = RestClient.post 'http://75.126.198.236:8080/signup', :fname => @invitation.recipient_firstname, :lname => @invitation.recipient_lastname, :uname => 'demo.user', :org => @invitation.recipient_company, :email => @invitation.recipient_email, :title => @invitation.recipient_title, :expires_at => ((@invitation.expires_at.to_i)*1000)
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

    puts "Calling sync service.."
    begin
      RestClient.post 'http://75.126.198.236:8080/sync/dldc', :uname => 'demo.user'
    rescue => e
      puts e
    end
    puts "Sync success"
  end
end
