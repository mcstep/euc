module Provisioners
  class GoogleAppsWorker < ProvisionerWorker
    def provision
      wait_until @user.provisioned? do
        instance = @user_integration.integration.google_apps_instance

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.google_apps.provision
          @user_integration.save!

          instance.register(
            "#{@user_integration.username}@#{@user_integration.integration.domain}",
            @user_integration.user.first_name,
            @user_integration.user.last_name,
          )

          if instance.group_name
            add_group instance.group_name, instance.group_region
          end
        end
      end
    end

    def deprovision
      instance = @user_integration.integration.google_apps_instance

      instance.unregister(
        "#{@user_integration.username}@#{@user_integration.integration.domain}"
      )

      if instance.group_name
        remove_group instance.group_name, instance.group_region
      end
    end
  end
end