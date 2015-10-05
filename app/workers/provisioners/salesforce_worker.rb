module Provisioners
  class SalesforceWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? && !instance.in_maintainance do
        user_integration.transaction do
          user_integration.salesforce.complete_application

          add_group(instance.group_name, instance.group_region) if instance.group_name

          unless user_integration.salesforce_user_id
            user_integration.salesforce_user_id = instance.register(
              user_integration.username, user.first_name, user.last_name, user_integration.email, user.email
            )
          else
            instance.update(user_integration.salesforce_user_id, isactive: true)
          end

          user_integration.save!
        end
      end
    end

    def revoke
      wait_until !instance.in_maintainance do
        user_integration.transaction do
          user_integration.salesforce.complete_application
          user_integration.save!

          instance.update(user_integration.salesforce_user_id, isactive: false)

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
        user_integration.salesforce.complete_application
        user_integration.save!
      end
    end
  end
end