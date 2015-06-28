require 'json'
require 'date'
require 'rqrcode_png'

class CustomProvisionWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    @invitation = Invitation.find(invitation_id)
    
    domain = ENV['DOMAIN']
    domain_suffix = ENV['CUSTOM_DOMAINS_SUFFIX']

    region = "dldc"
    if !@invitation.region.nil?
      region = @invitation.region.downcase
    end

    puts "Will start custom provisioning for #{@invitation.recipient_username}:#{@invitation.recipient_email}"

    account_created = false
    password = nil
    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/signup", 
                                  payload ={:fname => @invitation.recipient_firstname, 
                                            :lname => @invitation.recipient_lastname, 
                                            :username => @invitation.recipient_username, 
                                            :org => @invitation.recipient_company, 
                                            :email => @invitation.recipient_email, 
                                            :title => @invitation.recipient_title, 
                                            :expires_at => ((@invitation.expires_at.to_i)*1000), 
                                            :region => region,
                                            :domain_suffix => domain_suffix
                                            }, 
                                  headers={:token => ENV["API_KEY"]})

      if response.code == 200
        json_body = JSON.parse response
        @invitation.recipient_username = json_body['username']
        @invitation.save!
        account_created = true
        password = json_body['password']
      end
    rescue => e
      logger.error "error contacting AD server"
      puts "Exception during custom AD provisioning for #{@invitation.recipient_username}:#{@invitation.recipient_email} - Exception: #{e}"
    end

    puts "AD account created for #{@invitation.recipient_email}. Response from AD #{json_body}"
    
    puts "Creating user profile directory in home region for #{@invitation.recipient_username}.."
    begin
      create_dir_url = "#{ENV['API_HOST']}/createdir"
      response = RestClient.post( url=create_dir_url,
                                  payload={ :username => @invitation.recipient_username, 
                                            :region => region
                                          }, 
                                  headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    puts "Successfully created user profile directory in home region for #{@invitation.recipient_username}.."

    puts "Creating user profile directory in remaining regions for #{@invitation.recipient_username}...."
    rem_regions = ['amer', 'dldc', 'emea', 'apac'] - ["#{region}"]
    rem_regions.each do |sync_reg|
      begin
        create_dir_url = "#{ENV['API_HOST']}/createdir"
        response = RestClient.post( url=create_dir_url,
                                    payload={ :username => @invitation.recipient_username, 
                                              :region => sync_reg
                                            }, 
                                    headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
    end
    puts "Successfully created user profile directory in remaining regions for #{@invitation.recipient_username}.."


    puts "Adding user #{@invitation.recipient_username} to AD Groups"
    # Call Receiver to add user to appropriate Groups
    groups = ['TestdriveAppleUsers','O365Users','VIDMUsers']
    groups.each do |group_name|
      begin
        add_user_to_group_url = "#{ENV['API_HOST']}/addUserToGroup"
        response = RestClient.post(url=add_user_to_group_url,
                                  payload={ :username => @invitation.recipient_username,
                                            :domain_suffix => domain_suffix,
                                            :group => "#{group_name}"
                                          }, 
                                  headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
    end
    # Done calling Receiver to add user to appropriate Groups
    puts "Successfully added user #{@invitation.recipient_username} to AD Groups"
  
    CustomOfficeProvisionWorker.perform_async(invitation_id, password)

  end
end