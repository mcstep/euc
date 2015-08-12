module Provisioners
  class Office365Worker < ProvisionerWorker
    def provision
      wait_until @user.provisioned? do
        instance = @user_integration.integration.office365_instance
        email    = "#{@user_integration.username}@#{@user_integration.integration.domain}"

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.office365.complete_application
          @user_integration.save!

          instance.update_user email, 'usageLocation' => 'US'
          instance.assign_license email

          if instance.group_name
            add_group instance.group_name, instance.group_region
          end
        end
      end
    end

    def revoke
      instance = @user_integration.integration.office365_instance

      @user_integration.transaction do
        if @user_integration.office365_revoking? # unless we are running as `deprovision`
          @user_integration.office365.complete_application
          @user_integration.save!
        end

        @user_integration.directory.replicate('ad2')
        @user_integration.directory.office365_sync(@user_integration.username, @user_integration.integration.domain)

        if instance.group_name
          remove_group instance.group_name, instance.group_region
        end
      end
    end
  end
end