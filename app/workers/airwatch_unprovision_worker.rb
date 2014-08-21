require 'json'
require 'google/api_client'
require 'date'

class AirwatchUnprovisionWorker
  include Sidekiq::Worker

  def perform(invitation_id)
    invitation = Invitation.with_deleted.find_by_id(invitation_id)
    airwatch_id = invitation.airwatch_user_id
    domain = ENV['DOMAIN']

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

      result = client.execute(
        :api_method => directory.users.delete,
        :parameters => {'userKey' => "#{invitation.recipient_username}@#{domain}"}
      )

      puts result.body
      # TODO: Mark google response as successful
    rescue => e
      puts e
    end
    # Done calling Google API, now call AirWatch API

    #Call AirWatch API
    begin
    request_url = "https://testdrive.awmdm.com/API/v1/system/users/#{airwatch_id}/deactivate"
response = RestClient::Request.execute(:method => :post, :url => request_url, :user => "#{ENV['API_USER']}", :password => "#{ENV['API_PASSWORD']}", :headers => {:host => "testdrive.awmdm.com", :authorization => "Basic bW9oYW46bW9oYW4=", 'aw-tenant-code' => "#{ENV['AIRWATCH_TOKEN']}"})

    puts "AirWatch Account Deactivation for User #{invitation.recipient_username}, AirWatch ID #{airwatch_id}. Response Code: #{response.code}"
    rescue => e
      puts e
    end

    sleep 5 #Fix this. Currently have to do this because the AirWatch API can't handle deletion immediately after deactivation :(

    begin
      delete_url = "https://testdrive.awmdm.com/API/v1/system/users/#{airwatch_id}/delete"
response = RestClient::Request.execute(:method => :delete, :url => delete_url, :user => "#{ENV['API_USER']}", :password => "#{ENV['API_PASSWORD']}", :headers => {:host => "testdrive.awmdm.com", :authorization => "Basic bW9oYW46bW9oYW4=", 'aw-tenant-code' => "#{ENV['AIRWATCH_TOKEN']}"})
    puts "AirWatch Account Deletion for User #{invitation.recipient_username}, AirWatch ID #{airwatch_id}. Response Code: #{response.code}"    
    rescue => e
      puts e
    end
    #Done calling AirWatch API

  end
end
