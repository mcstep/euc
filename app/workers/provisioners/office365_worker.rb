module Provisioners
  class Office365Worker < ProvisionerWorker
    def provision
      wait_until user.provisioned? && !instance.in_maintainance do
        user_integration.transaction do
          user_integration.office365.complete_application
          user_integration.save!

          add_group(instance.group_name, instance.group_region) if instance.group_name

          user_integration.directory.replicate('ad2')
          user_integration.directory.office365_sync(
            user_integration.username,
            user_integration.integration.domain
          )

          sleep 30 unless Rails.env.test?

          instance.update_user user_integration.email, 'usageLocation' => 'US'
          instance.assign_license user_integration.email
        end
      end
    end

    def revoke
      wait_until !instance.in_maintainance do
        user_integration.transaction do
          user_integration.office365.complete_application
          user_integration.save!

          user_integration.directory.replicate('ad2')
          user_integration.directory.office365_sync_all

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
        user_integration.office365.complete_application
        user_integration.save!
      end
    end
  end
end