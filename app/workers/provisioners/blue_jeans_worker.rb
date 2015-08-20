module Provisioners
  class BlueJeansWorker < ProvisionerWorker
    def provision
      wait_until @user.provisioned? do
        instance = @user_integration.integration.blue_jeans_instance
        email    = "#{@user_integration.username}@#{@user_integration.integration.domain}"

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.blue_jeans.complete_application

          if instance.group_name
            add_group instance.group_name, instance.group_region
          end

          @user_integration.blue_jeans_user_id = instance.register(
            @user_integration.username, @user.first_name, @user.last_name, email, @user.company_name
          )
          @user_integration.save!

          instance.create_default_settings(@user_integration.blue_jeans_user_id)
        end
      end
    end

    def revoke
      instance = @user_integration.integration.blue_jeans_instance

      @user_integration.transaction do
        if @user_integration.blue_jeans_revoking? # unless we are running as `deprovision`
          @user_integration.blue_jeans.complete_application
          @user_integration.save!
        end

        instance.unregister(@user_integration.blue_jeans_user_id)

        if instance.group_name
          remove_group instance.group_name, instance.group_region
        end
      end
    end
  end
end