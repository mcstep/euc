require 'json'
require 'date'
require 'rqrcode_png'

class CustomAirwatchProvisionWorker
  include Sidekiq::Worker

  def perform(invitation_id, password)
    @invitation = Invitation.find(invitation_id)
    
    puts "Will start AirWatch provisioning for #{@invitation.recipient_username}:#{@invitation.recipient_email}"

    # Save EULA Accept date
    @invitation.eula_accept_date = Time.now
    @invitation.save!

    domain_suffix = ENV['CUSTOM_DOMAINS_SUFFIX']

    region = "dldc"
    if !@invitation.region.nil?
      region = @invitation.region.downcase
    end

    group_id = "1250"
    api_user = "api.admin"
    api_password = "$[5Jd#V7F."
    aw_tenant_code = "1LGKA4AAAAG5A5DACEAA"

    puts "Calling AW API to provision Enrollment User for #{@invitation.recipient_username}"
    #Call AirWatch API to create enrollment user
    begin
      # Check if this domain exists
      payload = { 'UserName' => "#{@invitation.recipient_username}", 
                  'Status' => "true",
                  'SecurityType' => "Directory", 
                  'Role' => "Full Access",
                  'LocationGroupId' => "#{group_id}",
                  'Group' => "#{group_id}"}
      response = RestClient::Request.execute(:method => :post, 
                                             :url => "https://apple.awmdm.com/API/v1/system/users/adduser", 
                                             :user => "#{api_user}", 
                                             :password => "#{api_password}", 
                                             :headers => {:content_type => :json, 
                                                          :accept => :json,  
                                                          :host => "apple.awmdm.com", 
                                                          :authorization => "Basic bW9oYW46bW9oYW4=", 
                                                          'aw-tenant-code' => "#{aw_tenant_code}"
                                                          }, 
                                             :payload => payload.to_json)
      response_json = JSON.parse(response.body)
      puts "Successfully called AW API to provision Enrollment User for #{@invitation.recipient_username}. AirWatch Response Value: #{response_json['Value']}"
      #Done calling AirWatch API

      #Update invitation with AirWatch user id
      @invitation.airwatch_user_id = response_json['Value']
      @invitation.save
    rescue => e
      puts e
    end

    puts "Calling AW API to provision Admin User for #{@invitation.recipient_username}"
    #Call AirWatch API to create Admin user
    begin
      # Check if this domain exists
      payload = {"UserName"=>"#{@invitation.recipient_username}", 
                 "LocationGroupId"=>"#{group_id}", 
                 "Roles"=>[ {
                              "Id" => "10107",
                              "LocationGroupId"=> "1956"
                            },
                            {
                              "Id"=> "10108",
                              "LocationGroupId"=> "1983"
                            },
                            {
                              "Id"=> "10109",
                              "LocationGroupId"=> "1977"
                            },
                            {
                              "Id"=> "10107",
                              "LocationGroupId"=> "1551"
                            },
                            {
                              "Id"=> "87",
                              "LocationGroupId"=> "1251"
                            },
                          ], 
                  "IsActiveDirectoryUser"=>"true", 
                  "RequiresPasswordChange"=>"false"} 
      response = RestClient::Request.execute(:method => :post, 
                                             :url => "https://apple.awmdm.com/api/v1/system/admins/addadminuser", 
                                             :user => "#{api_user}", 
                                             :password => "#{api_password}", 
                                             :headers => {:content_type => :json, 
                                                          :accept => :json,  
                                                          :host => "apple.awmdm.com", 
                                                          :authorization => "Basic bW9oYW46bW9oYW4=", 
                                                          'aw-tenant-code' => "#{aw_tenant_code}"
                                                          }, 
                                             :payload => payload.to_json)
      response_json = JSON.parse(response.body)
      puts "Successfully called AW API to provision Admin User for #{@invitation.recipient_username}. AirWatch Response Value: #{response_json['Value']}"

      #Update invitation with AirWatch user id
      @invitation.airwatch_admin_user_id = response_json['Value']
      @invitation.save
    rescue => e
      puts e
    end

    CustomHorizonSyncWorker.perform_async(invitation_id, password)
  end
end
