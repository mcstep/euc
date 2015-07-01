class CustomUnprovisionWorker
  include Sidekiq::Worker
  
  def perform(invitation_id)
    @invitation = Invitation.with_deleted.find_by_id(invitation_id)
    airwatch_id = @invitation.airwatch_user_id
    airwatch_admin_id = @invitation.airwatch_admin_user_id

    puts "Will start custom un-provisioning for #{@invitation.recipient_username}:#{@invitation.recipient_email}"
    
    puts "Calling ad replicate ad2.."
    begin
      ad_sync_url = "#{ENV['API_HOST']}/ad/replicate/ad2"
      RestClient::Request.execute(  :method => :post, 
                                    :url => ad_sync_url, 
                                    :timeout => 200, 
                                    :open_timeout => 10,  
                                    :payload => {:uname => 'demo.user'},  
                                    :headers => {:token => ENV["API_KEY"]})
    rescue => e
      puts e
    end
    puts "AD replicate ad2 called successfully"

    puts "Calling Office 365 Sync"
    begin
      ad_sync_url = "#{ENV['API_HOST']}/office365/sync/all"
      RestClient::Request.execute(  :method => :post, 
                                    :url => ad_sync_url, 
                                    :timeout => 200, 
                                    :open_timeout => 10,  
                                    :payload => {:uname => "#{@invitation.recipient_username}"},  
                                    :headers => {:token => ENV["API_KEY"]})
    rescue => e
      puts e
    end
    puts "Successfully called Office 365 Sync"


    group_id = "1250"
    api_user = "api.admin"
    api_password = "$[5Jd#V7F."
    aw_tenant_code = "1LGKA4AAAAG5A5DACEAA"

    if !airwatch_id.nil?
      #Call AirWatch API
      begin
        request_url = "https://apple.awmdm.com/API/v1/system/users/#{airwatch_id}/deactivate"
        response = RestClient::Request.execute( :method => :post, 
    									    	:url => request_url, 
    									    	:user => "#{api_user}", 
    									    	:password => "#{api_password}", 
    									    	:headers => { :host => "apple.awmdm.com", 
    									    		:authorization => "Basic bW9oYW46bW9oYW4=", 
    									    		'aw-tenant-code' => "#{aw_tenant_code}"
    									    	}
      	)

        puts "AirWatch Account Deactivation for User #{@invitation.recipient_username}, AirWatch ID #{airwatch_id}. Response Code: #{response.code}"
      rescue => e
        puts e
      end

      sleep 5 #Fix this. Currently have to do this because the AirWatch API can't handle deletion immediately after deactivation :(

      begin
        delete_url = "https://apple.awmdm.com/API/v1/system/users/#{airwatch_id}/delete"
      response = RestClient::Request.execute( :method => :delete, 
                          :url => delete_url, 
                          :user => "#{api_user}", 
                          :password => "#{api_password}", 
                          :headers => { :host => "apple.awmdm.com", 
                                  :authorization => "Basic bW9oYW46bW9oYW4=", 
                                  'aw-tenant-code' => "#{aw_tenant_code}"})
        puts "AirWatch Account Deletion for User #{@invitation.recipient_username}, AirWatch ID #{airwatch_id}. Response Code: #{response.code}"    
      rescue => e
        puts e
      end
    end
    #Done calling AirWatch API

    if !airwatch_admin_id.nil?
      begin
        delete_url = "https://apple.awmdm.com/API/v1/system/admins/#{airwatch_admin_id}/delete"
      response = RestClient::Request.execute( :method => :delete, 
                          :url => delete_url, 
                          :user => "#{api_user}", 
                          :password => "#{api_password}", 
                          :headers => { :host => "apple.awmdm.com", 
                                  :authorization => "Basic bW9oYW46bW9oYW4=", 
                                  'aw-tenant-code' => "#{aw_tenant_code}"})
        puts "AirWatch Admin Account Deletion for User #{@invitation.recipient_username}, AirWatch ID #{airwatch_id}. Response Code: #{response.code}"    
      rescue => e
        puts e
      end
    end
    #Done calling AirWatch API


    puts "Calling ad replicate amer.."
    begin
      ad_sync_url = "#{ENV['API_HOST']}/ad/replicate/amer"
      RestClient::Request.execute(  :method => :post, 
                                    :url => ad_sync_url, 
                                    :timeout => 200, 
                                    :open_timeout => 10,  
                                    :payload => {:uname => 'demo.user'},  
                                    :headers => {:token => ENV["API_KEY"]})
    rescue => e
      puts e
    end
    puts "AD replicate amer called successfully"

    puts "Calling receiver to perform Horizon Sync..."
    begin
      home_sync_url = "#{ENV['API_HOST']}/sync/vidm"
      response = RestClient.post(url=home_sync_url,
                                 payload={:uname => 'demo.user'}, 
                                 headers= {:token => ENV["API_KEY"]})
      puts response.body
      puts "VIDM sync success"
    rescue => e
      puts e
    end

  end
end