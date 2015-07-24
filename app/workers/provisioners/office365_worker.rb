module Provisioners
  class Office365Worker < ProvisionerWorker
    def provision
      wait_until @user.provisioned? do
        instance = @user_integration.integration.office365_instance
        email    = "#{@user_integration.username}@#{@user_integration.integration.domain}"

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.office365.provision
          @user_integration.save!

          instance.update_user email, 'usageLocation' => 'US'
          instance.assign_license email

          if instance.group_name
            add_group instance.group_name, instance.group_region
          end
        end
      end
    end

    def deprovision
      instance = @user_integration.integration.office365_instance

      if instance.group_name
        remove_group instance.group_name, instance.group_region
      end
    end
  end
end