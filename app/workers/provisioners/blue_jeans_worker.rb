module Provisioners
  class BlueJeansWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? && !instance.in_maintainance do
        user_integration.transaction do
          user_integration.blue_jeans.complete_application

          add_group(instance.group_name, instance.group_region) if instance.group_name

          user_integration.blue_jeans_user_id = instance.register(
            user_integration.username,
            user.first_name,
            user.last_name,
            user_integration.email,
            user.company_name
          )
          user_integration.save!

          instance.create_default_settings(user_integration.blue_jeans_user_id)
        end
      end
    end

    def revoke
      wait_until !instance.in_maintainance do
        user_integration.transaction do
          user_integration.blue_jeans.complete_application
          user_integration.save!

          remove_group(instance.group_name, instance.group_region) if instance.group_name
        end
      end
    end

    def resume
      wait_until !instance.in_maintainance do
        user_integration.transaction do
          user_integration.blue_jeans.complete_application
          user_integration.save!

          add_group(instance.group_name, instance.group_region) if instance.group_name
        end
      end
    end

    def deprovision
      wait_until !instance.in_maintainance do
        unless user_integration.blue_jeans_removal_requested_at?
          user_integration.transaction do
            user_integration.blue_jeans_removal_requested_at = DateTime.now
            user_integration.save!

            instance.unregister(user_integration.blue_jeans_user_id)
            GeneralMailer.blue_jeans_removal_email(instance.support_emails, user_integration).deliver_now
          end
        end

        wait_until DateTime.now - user_integration.blue_jeans_removal_requested_at.to_datetime > 5, 1.day do
          user_integration.blue_jeans.complete_application
          user_integration.save!
        end
      end
    end
  end
end