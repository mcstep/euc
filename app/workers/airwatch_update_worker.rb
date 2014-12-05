require 'json'

class AirwatchUpdateWorker
  include Sidekiq::Worker

  def perform(invitation_id, sync_type)
    invitation = Invitation.find_by_id(invitation_id)
    domain = ENV['DOMAIN']

    # TODO: Call Google API to 'suspend' user. Phase #2

    #Call AirWatch API
    begin
    airwatch_id = invitation.airwatch_user_id
  
    request_url = ""
    request_type = ""
    if sync_type == true # This is an activation
      request_type = "activation"
      request_url = "https://testdrive.awmdm.com/API/v1/system/users/#{airwatch_id}/activate"
    else # This is a deactivation
      request_type = "deactivaion"
      request_url = "https://testdrive.awmdm.com/API/v1/system/users/#{airwatch_id}/deactivate"
    end

    response = RestClient::Request.execute(:method => :post, :url => request_url, :user => "#{ENV['API_USER']}", :password => "#{ENV['API_PASSWORD']}", :headers => {:host => "testdrive.awmdm.com", :authorization => "Basic bW9oYW46bW9oYW4=", 'aw-tenant-code' => "#{ENV['AIRWATCH_TOKEN']}"})
    puts "AirWatch Account #{request_type} for User #{invitation.recipient_username}, AirWatch ID #{airwatch_id}. Response Code: #{response.code}"
    
    if request_type == "activation"
      WelcomeUserMailer.airwatch_user_reactivation_email(invitation).deliver
      # Call Receiver to add user to AirWatch Group
      begin
        add_user_to_group_url = "#{ENV['API_HOST']}/addUserToGroup"
        response = RestClient.post(url=add_user_to_group_url,payload={:username => invitation.recipient_username, :group => 'AirWatchUsers'}, headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
      # Done calling Receiver to add user to AirWatch Group
    else
      WelcomeUserMailer.airwatch_user_deactivation_email(invitation).deliver
      # Call Receiver to remove user from AirWatch Group
      begin
        add_user_to_group_url = "#{ENV['API_HOST']}/removeUserFromGroup"
        response = RestClient.post(url=add_user_to_group_url,payload={:username => invitation.recipient_username, :group => 'AirWatchUsers'}, headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
      # Done calling Receiver to remove user from AirWatch Group
    end

    puts "Calling sync service for workspace.."
    begin
      home_sync_url = "#{ENV['API_HOST']}/sync/dldc"
      response = RestClient.post(url=home_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    puts "Sync success"

    #Done calling AirWatch API    
    rescue => e
      puts e
    end
  end
end
