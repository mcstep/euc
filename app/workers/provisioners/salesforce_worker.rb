module Provisioners
  class SalesforceWorker < ProvisionerWorker
    def provision
      wait_until @user.provisioned? do
        instance = @user_integration.integration.salesforce_instance

        # Only tick status if everything worked (retry otherwise)
        @user_integration.transaction do
          @user_integration.salesforce.complete_application

          if instance.group_name
            add_group instance.group_name, instance.group_region
          end

          unless @user_integration.salesforce_user_id
            @user_integration.salesforce_user_id = instance.register(
              @user_integration.username, @user.first_name, @user.last_name, @user_integration.email
            )
          else
            instance.update(@user_integration.salesforce_user_id, isactive: true)
          end

          @user_integration.save!
        end
      end
    end

    def revoke
      instance = @user_integration.integration.salesforce_instance

      @user_integration.transaction do
        if @user_integration.salesforce_revoking? # unless we are running as `deprovision`
          @user_integration.salesforce.complete_application
          @user_integration.save!
        end

        instance.update(@user_integration.salesforce_user_id, isactive: false)

        if instance.group_name
          remove_group instance.group_name, instance.group_region
        end
      end
    end
  end
end