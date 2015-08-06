module Provisioners
  class AirwatchWorker < ProvisionerWorker
    def provision
      wait_until(
        @user.provisioned? && 
        (@user_integration.office365_disabled || @user_integration.office365_provisioned?) &&
        (@user_integration.google_apps_disabled || @user_integration.google_apps_provisioned?)
      ) do
        instance = @user_integration.integration.airwatch_instance

        # Make sure to store it because add_user is not an idempotent method
        unless @user_integration.airwatch_user_id
          @user_integration.airwatch_user_id = instance.add_user(@user_integration.username)['Value']
          @user_integration.save!
        end

        if @user.profile.airwatch_admins_supported
          # Same goes to add_admin_user
          unless @user_integration.airwatch_admin_user_id
            @user_integration.airwatch_admin_user_id = instance.add_admin_user(@user_integration.username)['Value']
            @user_integration.save!
          end
        end

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.airwatch.provision
          @user_integration.airwatch_group = AirwatchGroup.instantiate(@user_integration)
          @user_integration.save!

          add_group instance.group_name, instance.group_region

          GeneralMailer.airwatch_activation_email(@user_integration).deliver_now
        end
      end
    end

    def deprovision
      instance = @user_integration.integration.airwatch_instance

      instance.delete_user(@user_integration.airwatch_user_id)
      remove_group instance.group_name, instance.group_region
    end

    def revoke
      instance = @user_integration.integration.airwatch_instance

      instance.deactivate(@user_integration.airwatch_user_id)
      remove_group instance.group_name, instance.group_region

      GeneralMailer.airwatch_deactivation_email(@user_integration).deliver_now
    end

    def resume
      instance = @user_integration.integration.airwatch_instance

      instance.activate(@user_integration.airwatch_user_id)
      add_group instance.group_name, instance.group_region

      GeneralMailer.airwatch_reactivation_email(@user_integration).deliver_now
    end

    def cleanup
      deprovision(@user_integration)
    end
  end
end