module Provisioners
  class GoogleAppsWorker < ProvisionerWorker
    def client(instance)
      return @client if @client

      @client = Google::APIClient.new(
        application_name: 'EUC Global Demo Portal',
        application_version: '1.0.0'
      )

      # Load our credentials for the service account
      key      = Google::APIClient::KeyUtils.load_from_pkcs12(instance.key_file, instance.key_password)
      asserter = Google::APIClient::JWTAsserter.new(instance.service_account, 'https://www.googleapis.com/auth/admin.directory.user', key)

      @client.authorization = asserter.authorize(instance.act_on_behalf)
      @client.authorization.fetch_access_token!

      @client
    end

    def provision(user_integration)
      user_integration.google_apps.provision

      instance = user_integration.integration.google_apps_instance
      user     = user_integration.user

      directory = client.discovered_api('admin', 'directory_v1')
      result    = client.execute(
        api_method: directory.users.insert,
        body_object: directory.users.insert.request_schema.new(
          name: { familyName: "#{user.last_name}", givenName: "#{user.first_name}" },
          primaryEmail: "#{user_integration.directory_username}@#{user_integration.integration.domain}",
          password: instance.initial_password
        )
      )

      user_integration.save!
    end

    def deprovision(user_integration)
      instance = user_integration.integration.google_apps_instance
      user     = user_integration.user

      directory = client.discovered_api('admin', 'directory_v1')
      result    = client.execute(
        api_method: directory.users.delete,
        parameters: {'userKey' => "#{user_integration.directory_username}@#{user_integration.integration.domain}"}
      )
    end
  end
end