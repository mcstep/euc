module Provisioners
  class GoogleAppsWorker < ProvisionerWorker
    def provision(user_integration)
      user_integration.transaction do
        user_integration.google_apps.provision
        user_integration.save!

        user_integration.integration.google_apps_instance.register(
          "#{user_integration.directory_username}@#{user_integration.integration.domain}",
          user_integration.user.first_name,
          user_integration.user.last_name,
        )
      end
    end

    def deprovision(user_integration)
      user_integration.integration.google_apps_instance.unregister(
        "#{user_integration.directory_username}@#{user_integration.integration.domain}"
      )
    end
  end
end