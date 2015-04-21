require 'json'
require 'google/api_client'
require 'date'
require 'rqrcode_png'

class AirwatchProvisionWorker
  include Sidekiq::Worker

  def perform(user_id)
    usr = User.find_by_id(user_id)
    invitation = Invitation.find(usr.invitation_id)
    domain = ENV['DOMAIN']
    password = 'Passw0rd1' # Yes, all google accounts are initially created with this default password. AirWatch will take care of the rest.

    #Call Google API
    begin
      # Update these to match your own apps credentials
      service_account_email = '1022878145273-bbsae5pdlpj4mh0f49icrvcgtfo78a6u@developer.gserviceaccount.com' # Email of service account
      act_on_behalf_email = 'admin@vmwdemo.com'
      add_user_scope = 'https://www.googleapis.com/auth/admin.directory.user'

      key_file = Rails.root.join('config','privatekey.p12').to_s # File containing your private key
      key_secret = 'notasecret' # Password to unlock private key

      client = Google::APIClient.new(
      :application_name => 'EUC Global Demo Portal',
      :application_version => '1.0.0')

      # Load our credentials for the service account
      key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
      asserter = Google::APIClient::JWTAsserter.new(service_account_email, add_user_scope, key)

      client.authorization = asserter.authorize(act_on_behalf_email)

      # Request a token for our service account
      client.authorization.fetch_access_token!

      directory = client.discovered_api('admin', 'directory_v1')

      new_user = directory.users.insert.request_schema.new(
        name: { familyName: "#{invitation.recipient_lastname}", givenName: "#{invitation.recipient_firstname}" },
        primaryEmail: "#{invitation.recipient_username}@#{domain}",
        password: "#{password}"
      )

      result = client.execute(
       :api_method => directory.users.insert,
       :body_object => new_user
      )

      puts result.body
      # TODO: Mark google response as successful
    rescue => e
      puts e
    end
    # Done calling Google API, now call AirWatch API

    # Call AirWatch API to create Group ID
    user_domain = usr.email.split("@").last

    # Check if this domain exists
    user_domain_exists = AirwatchGroup.find_by_domain(user_domain)

    # If the domain doesn't exist, create it
    if user_domain_exists.nil?
      puts "Domain does not exist - creating Group ID for domain #{user_domain}"
      begin
        aw_req_payload = { 'Name' => "#{user_domain}", 'GroupId' => "#{user_domain[0...20].gsub('.','-')}",'LocationGroupType' => 'Prospect', 'AddDefaultLocation' => 'Yes'}.to_json
        response = RestClient::Request.execute(:method => :post, :url => "https://testdrive.awmdm.com/API/v1/system/groups/#{ENV['PARENT_GROUP_ID']}/creategroup", :user => "#{ENV['API_USER']}", :password => "#{ENV['API_PASSWORD']}", :headers => {:content_type => :json, :accept => :json,  :host => "testdrive.awmdm.com", :authorization => "Basic bW9oYW46bW9oYW4=", 'aw-tenant-code' => "#{ENV['AIRWATCH_TOKEN']}"}, :payload => aw_req_payload)
        response_json = JSON.parse(response.body)
        puts "AirWatch Response Value: #{response_json['Value']}"

        # Create and save it in the DB
        airwatch_group = AirwatchGroup.new
        airwatch_group.domain = user_domain
        airwatch_group.group_id = user_domain.gsub('.','-')
        airwatch_group.name = usr.company
        airwatch_group.group_type = 'Prospect'
        airwatch_group.parent_id = ENV['PARENT_GROUP_ID'].to_i
        airwatch_group.group_id_num = response_json['Value'].to_i

        airwatch_group.save

        puts "AirWatch Organization Group: #{airwatch_group.group_id}-#{response_json['Value']} saved successfully"
      rescue => e
        puts e
      end
    else
      puts "Domain exists - sending enrollment instructions email with existing Group ID"
    end
    # Done calling AirWatch API to create Group ID

    #Call AirWatch API
    begin
      # Check if this domain exists
      user_domain_exists = AirwatchGroup.find_by_domain(user_domain)
      payload = nil
      if !user_domain_exists.nil?
        numId = user_domain_exists.group_id_num
        # payload = { 'UserName' => "#{usr.username}", 'Status' => "true",'SecurityType' => "Directory", 'Group' => "#{numId}", 'LocationGroupId' => "#{numId}"}
        payload = { 'UserName' => "#{usr.username}", 'Status' => "true",'SecurityType' => "Directory", 'Role' => "VMWDemo"}
      else
        payload = { 'UserName' => "#{usr.username}", 'Status' => "true",'SecurityType' => "Directory", 'Role' => "VMWDemo"}
      end
      response = RestClient::Request.execute(:method => :post, :url => "https://testdrive.awmdm.com/API/v1/system/users/adduser", :user => "#{ENV['API_USER']}", :password => "#{ENV['API_PASSWORD']}", :headers => {:content_type => :json, :accept => :json,  :host => "testdrive.awmdm.com", :authorization => "Basic bW9oYW46bW9oYW4=", 'aw-tenant-code' => "#{ENV['AIRWATCH_TOKEN']}"}, :payload => payload.to_json)
      response_json = JSON.parse(response.body)
      puts "AirWatch Response Value: #{response_json['Value']}"
      #Done calling AirWatch API

      #Update invitation with AirWatch user id
      invitation.airwatch_user_id = response_json['Value']
      invitation.save
    rescue => e
      puts e
    end

    # Call Receiver to add user to AirWatch Group
    begin
      add_user_to_group_url = "#{ENV['API_HOST']}/addUserToGroup"
      response = RestClient.post(url=add_user_to_group_url,payload={:username => invitation.recipient_username, :group => 'AirWatchUsers'}, headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    # Done calling Receiver to add user to AirWatch Group

    puts "Calling sync service for workspace.."
    begin
      home_sync_url = "#{ENV['API_HOST']}/sync/dldc"
      response = RestClient.post(url=home_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    puts "Sync success"

    # Send enrollment instructions email to user
    puts "Sending enrollment instructions email to user"
      path_to_file = "#{Rails.root}/tmp/temp.png"
      @qr = RQRCode::QRCode.new("https://awagent.com/Home/Welcome?gid=#{user_domain.gsub('.','-')}&serverurl=testdrive.awmdm.com", :size => 10).to_img.resize(200, 200).save(path_to_file)
      cloud = Cloudinary::Uploader.upload(path_to_file)
      File.delete(path_to_file) if File.exist?(path_to_file)
      WelcomeUserMailer.airwatch_user_activation_email(invitation,user_domain.gsub('.','-'),user_domain, cloud['url']).deliver
    puts "Done sending enrollment instructions email to user"
    # Done sending enrollment instructions email to user
  end
end
