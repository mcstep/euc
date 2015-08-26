module Provisioners
  class HorizonViewWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? do
        directory = user_integration.integration.directory

        user_integration.transaction do
          user_integration.horizon_view.complete_application
          user_integration.save!

          User::REGIONS.each do |region|
            directory.create_profile(user_integration.username, region, user_integration.integration.domain)
          end

          add_group(instance.view_group_name, instance.group_region) if instance.view_group_name
        end
      end
    end

    def revoke
      user_integration.transaction do
        user_integration.horizon_view.complete_application
        user_integration.save!

        remove_group(instance.view_group_name, instance.group_region) if instance.view_group_name
      end
    end

    def resume
      provision
    end

    def deprovision
      user_integration.horizon_view.complete_application
      user_integration.save!
    end
  end
end