require 'json'
require 'google/api_client'
require 'date'
require 'rqrcode_png'

class GoogleProvisionWorker
  include Sidekiq::Worker

  def perform(user_id)
    usr = User.find_by_id(user_id)
    invitation = Invitation.find_by_recipient_username(usr.username)
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
    # Done calling Google API
  end
end
