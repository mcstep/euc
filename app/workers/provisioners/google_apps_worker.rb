module Provisioners
  class GoogleAppsWorker < ProvisionerWorker
    def provision(user_integration)
      instance = user_integration.integration.google_apps_instance

      user_integration.transaction do
        user_integration.google_apps.provision
        user_integration.save!

        instance.register(
          "#{user_integration.username}@#{user_integration.integration.domain}",
          user_integration.user.first_name,
          user_integration.user.last_name,
        )

        if instance.group_name
          add_group user_integration, instance.group_name, instance.group_region
        end
      end
    end

    def deprovision(user_integration)
      instance = user_integration.integration.google_apps_instance

      instance.unregister(
        "#{user_integration.username}@#{user_integration.integration.domain}"
      )

      if instance.group_name
        remove_group user_integration, instance.group_name, instance.group_region
      end
    end
  end
end