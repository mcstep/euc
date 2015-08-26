module Provisioners
  class GoogleAppsWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? do
        user_integration.transaction do
          user_integration.google_apps.complete_application
          user_integration.save!

          instance.register(
            user_integration.email,
            user_integration.user.first_name,
            user_integration.user.last_name,
          )

          add_group(instance.group_name, instance.group_region) if instance.group_name
        end
      end
    end

    def revoke
      user_integration.transaction do
        user_integration.google_apps.complete_application
        user_integration.save!

        instance.unregister user_integration.email

        remove_group(instance.group_name, instance.group_region) if instance.group_name
      end
    end

    def resume
      provision
    end

    def deprovision
      user_integration.google_apps.complete_application
      user_integration.save!
    end
  end
end