module Provisioners
  class SalesforceWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? do
        user_integration.transaction do
          user_integration.salesforce.complete_application

          add_group(instance.group_name, instance.group_region) if instance.group_name

          unless user_integration.salesforce_user_id
            user_integration.salesforce_user_id = instance.register(
              user_integration.username, user.first_name, user.last_name, user_integration.email
            )
          else
            instance.update(user_integration.salesforce_user_id, isactive: true)
          end

          user_integration.save!
        end
      end
    end

    def revoke
      user_integration.transaction do
        user_integration.salesforce.complete_application
        user_integration.save!

        instance.update(user_integration.salesforce_user_id, isactive: false)

        remove_group(instance.group_name, instance.group_region) if instance.group_name
      end
    end

    def resume
      provision
    end

    def deprovision
      user_integration.salesforce.complete_application
      user_integration.save!
    end
  end
end