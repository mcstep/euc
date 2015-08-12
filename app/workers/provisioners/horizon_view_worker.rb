module Provisioners
  class HorizonViewWorker < ProvisionerWorker
    def provision
      wait_until @user.provisioned? do
        instance  = @user_integration.integration.horizon_view_instance
        directory = @user_integration.integration.directory

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.horizon_view.complete_application
          @user_integration.save!

          User::REGIONS.each do |region|
            directory.create_profile(@user_integration.username, region, @user_integration.integration.domain)
          end

          if instance.view_group_name
            add_group instance.view_group_name, instance.group_region
          end
        end
      end
    end

    def revoke
      instance = @user_integration.integration.horizon_view_instance

      @user_integration.transaction do
        if @user_integration.horizon_view_revoking? # unless we are running as `deprovision`
          @user_integration.horizon_view.complete_application
          @user_integration.save!
        end

        if instance.view_group_name
          remove_group instance.view_group_name, instance.group_region
        end
      end
    end
  end
end