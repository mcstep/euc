class BatchSignupWorker
  # Same as SignupWorker but without the AD Replicate call that takes forever - TEMPORARY until we move to new schema/app
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.find_by_id(invitation_id)
    puts "BATCH: Will start working on Invitation ID#{invitation_id} for Recipient #{@invitation.recipient_email}"

    region = "dldc"
    if !@invitation.region.nil?
      region = @invitation.region.downcase
    end

    account_created = false
    begin
      response = RestClient.post(url="#{ENV['API_HOST']}/signup", payload ={:fname => @invitation.recipient_firstname, :lname => @invitation.recipient_lastname, :username => @invitation.recipient_username, :org => @invitation.recipient_company, :email => @invitation.recipient_email, :title => @invitation.recipient_title, :expires_at => ((@invitation.expires_at.to_i)*1000), :region => region}, headers={:token => ENV["API_KEY"]})

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

    puts "BATCH: Done creating account. Response from AD #{json_body}"

    if account_created == true
      # TODO: merge this and the following block?
      puts "BATCH:Creating user profile directory in home region.."
      begin
        create_dir_url = "#{ENV['API_HOST']}/createdir"
        response = RestClient.post(url=create_dir_url,payload={:username => @invitation.recipient_username, :region => region}, headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
      puts "BATCH: Created user profile directory successfully in home region"

      puts "BATCH: Creating user profile directory in remaining regions.."
      rem_regions = ['amer', 'dldc', 'emea', 'apac'] - ["#{region}"]
      rem_regions.each do |sync_reg|
        begin
          create_dir_url = "#{ENV['API_HOST']}/createdir"
          response = RestClient.post(url=create_dir_url,payload={:username => @invitation.recipient_username, :region => sync_reg}, headers= {:token => ENV["API_KEY"]})
          puts response.body
        rescue => e
          puts e
        end
      end
      puts "BATCH: Created user profile directory successfully in other regions"

      # Find a way to optimize this
      super_user = false
      # find the corresponding invitation and check if the user signed up with a reg_code
      inv_for_user = @invitation
      if !inv_for_user.nil? && !inv_for_user.reg_code_id.nil?
        reg_code = RegCode.find_by_id(inv_for_user.reg_code_id)
        if !reg_code.nil? && (reg_code.account_type == 1) # 1 = vip
          super_user = true
        end
      else
        domain_name = @invitation.recipient_email.split("@").last
        @domain = Domain.find_by_name(domain_name)
        if !@domain.nil? && @domain.status == 'active'
          super_user = true
        end
      end

      if super_user == true
        puts "BATCH: Sending Super User email for Invitation #{@invitation.id}...."
          WelcomeUserMailer.welcome_email(@invitation,json_body['password'],ENV['DOMAIN']).deliver
        puts "BATCH: Email sent successfully for Invitation #{@invitation.id}"
      else
        puts "BATCH: Sending Regular User email for Invitation #{@invitation.id}...."
          WelcomeUserMailer.welcome_email_invited(@invitation,json_body['password'],ENV['DOMAIN']).deliver
        puts "BATCH: Email sent successfully for Invitation #{@invitation.id}"
      end

    else
      puts "BATCH: AD account creation failed for #{@invitation.recipient_email}. Will stop provisioning"
    end
  end
end
