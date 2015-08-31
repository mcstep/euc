module Provisioners
  class AirwatchWorker < ProvisionerWorker
    def provision
      wait_until(
        user.provisioned? && 
        (user_integration.office365_disabled? || user_integration.office365_provisioned?) &&
        (user_integration.google_apps_disabled? || user_integration.google_apps_provisioned?)
      ) do
          # unless user_integration.airwatch_user_id
            user_integration.airwatch_user_id = instance.add_user(user_integration.username)['Value']
            user_integration.save!
          # end

        if instance.use_admin
          # unless user_integration.airwatch_admin_user_id
            user_integration.airwatch_admin_user_id = instance.add_admin_user(user_integration)['Value']
            user_integration.save!
          # end
        end

        user_integration.transaction do
          user_integration.airwatch.complete_application

          if instance.use_groups
            user_integration.airwatch_group = AirwatchGroup.produce(user_integration)
          end

          user_integration.save!

          if instance.group_name
            add_group instance.group_name, instance.group_region
          end

          if instance.use_groups
            GeneralMailer.airwatch_activation_email(user).deliver_now
          end
        end
      end
    end

    def revoke
      user_integration.transaction do
        user_integration.airwatch.complete_application
        user_integration.save!

        instance.deactivate(user_integration.airwatch_user_id)

        if instance.group_name
          remove_group instance.group_name, instance.group_region
        end

        if instance.use_groups
          GeneralMailer.airwatch_deactivation_email(user).deliver_now
        end
      end
    end

    def resume
      user_integration.transaction do
        user_integration.airwatch.complete_application
        user_integration.save!

        instance.activate(user_integration.airwatch_user_id)

        if instance.group_name
          add_group instance.group_name, instance.group_region
        end

        if instance.use_groups
          GeneralMailer.airwatch_reactivation_email(user).deliver_now
        end
      end
    end

    def deprovision
      sleep 10

      instance.delete_user(user_integration.airwatch_user_id)

      if user_integration.airwatch_admin_user_id
        instance.delete_admin_user(user_integration.airwatch_admin_user_id)
      end
    end

    def cleanup
      deprovision(user_integration)
    end
  end
end