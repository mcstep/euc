module Provisioners
  class GoogleAppsWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? && !instance.in_maintainance do
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
      wait_until !instance.in_maintainance do
        user_integration.transaction do
          user_integration.google_apps.complete_application
          user_integration.save!

          instance.unregister user_integration.email

          remove_group(instance.group_name, instance.group_region) if instance.group_name
        end
      end
    end

    def resume
      wait_until !instance.in_maintainance do
        provision
      end
    end

    def deprovision
      wait_until !instance.in_maintainance do
        user_integration.google_apps.complete_application
        user_integration.save!
      end
    end
  end
end