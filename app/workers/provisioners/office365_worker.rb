module Provisioners
  class Office365Worker < ProvisionerWorker
    def provision
      wait_until user.provisioned? do
        user_integration.transaction do
          user_integration.office365.complete_application
          user_integration.save!

          add_group(instance.group_name, instance.group_region) if instance.group_name

          user_integration.directory.replicate('ad2')
          user_integration.directory.office365_sync(
            user_integration.username,
            user_integration.integration.domain
          )

          sleep 30

          instance.update_user user_integration.email, 'usageLocation' => 'US'
          instance.assign_license user_integration.email
        end
      end
    end

    def revoke
      user_integration.transaction do
        user_integration.office365.complete_application
        user_integration.save!

        user_integration.directory.replicate('ad2')
        user_integration.directory.office365_sync_all

        remove_group(instance.group_name, instance.group_region) if instance.group_name
      end
    end

    def resume
      provision
    end

    def deprovision
      user_integration.office365.complete_application
      user_integration.save!
    end
  end
end