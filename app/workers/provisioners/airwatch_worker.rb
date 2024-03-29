module Provisioners
  class AirwatchWorker < ProvisionerWorker
    def provision
      wait_until(
        user.provisioned? &&
        !instance.in_maintainance &&
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

          # if instance.use_templates
          #   user_integration.airwatch_sandbox_admin_group_id = instance.add_group(
          #     "Sandbox Admin #{user_integration.username}",
          #     user_integration.airwatch_template['Sandbox Admin']
          #   )
          #   user_integration.save!
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
            GeneralMailer.airwatch_activation_email(user_integration).deliver_now
          end

          if instance.use_templates
            GeneralMailer.airwatch_templates_activation_email(user_integration).deliver_now
          end
        end
      end
    end

    def revoke
      wait_until !instance.in_maintainance do
        # Run out of common transaction to minimize risks
        if user_integration.airwatch_admin_user_id
          user_integration.transaction do
            instance.delete_admin_user(user_integration.airwatch_admin_user_id)
            user_integration.airwatch_admin_user_id = nil
            user_integration.save!
          end
        end

        # Run out of common transaction to minimize risks
        # if user_integration.airwatch_sandbox_admin_group_id
        #   user_integration.transaction do
        #     instance.delete_group(user_integration.airwatch_sandbox_admin_group_id)
        #     user_integration.airwatch_sandbox_admin_group_id = nil
        #     user_integration.save!
        #   end
        # end

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
    end

    def resume
      wait_until !instance.in_maintainance do
        # Run out of common transaction to minimize risks
        if instance.use_admin
          unless user_integration.airwatch_admin_user_id
            user_integration.airwatch_admin_user_id = instance.add_admin_user(user_integration)['Value']
            user_integration.save!
          end

          # if instance.use_templates
          #   unless user_integration.airwatch_sandbox_admin_group_id
          #     user_integration.airwatch_sandbox_admin_group_id = instance.add_group(
          #       "Sandbox Admin #{user_integration.username}",
          #       user_integration.airwatch_template['Sandbox Admin']
          #     )
          #     user_integration.save!
          #   end
          # end
        end

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
    end

    def deprovision
      wait_until !instance.in_maintainance do
        sleep 10 unless Rails.env.test?

        if user_integration.airwatch_user_id
          user_integration.transaction do
            instance.delete_user(user_integration.airwatch_user_id)
            user_integration.airwatch_user_id = nil
            user_integration.save!
          end
        end

        if user_integration.airwatch_admin_user_id
          user_integration.transaction do
            instance.delete_admin_user(user_integration.airwatch_admin_user_id)
            user_integration.airwatch_admin_user_id = nil
            user_integration.save!
          end
        end
      end
    end
  end
end