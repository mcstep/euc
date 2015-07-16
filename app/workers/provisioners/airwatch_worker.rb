module Provisioners
  class AirwatchWorker < ProvisionerWorker
    def provision(user_integration)
      # Make sure to store it because add_user is not an idempotent method
      unless user_integration.airwatch_user_id
        user_integration.airwatch_user_id = instance.add_user(user_integration.directory_username)['Value']
        user_integration.save!
      end

      # Only tick status if everything worked (retry otherwise)
      user_integration.transaction do
        user_integration.airwatch.provision
        user_integration.save!

        instance = user_integration.integration.airwatch_instance
        user_integration.airwatch_group_id = AirwatchGroup.instantiate(user_integration)
        add_group user_integration, instance.group_name, instance.group_region

        GeneralMailer.airwatch_activation_email(user_integration).deliver
      end
    end

    def deprovision(user_integration)
      instance = user_integration.integration.airwatch_instance

      instance.delete_user(user_integration.airwatch_user_id)
      remove_group user_integration, instance.group_name, instance.group_region
    end

    def revoke(user_integration)
      instance = user_integration.integration.airwatch_instance

      instance.deactivate(user_integration.airwatch_user_id)
      remove_group user_integration, instance.group_name, instance.group_region

      GeneralMailer.airwatch_deactivation_email(user_integration).deliver
    end

    def resume(user_integration)
      instance = user_integration.integration.airwatch_instance

      instance.activate(user_integration.airwatch_user_id)
      add_group user_integration, instance.group_name, instance.group_region

      GeneralMailer.airwatch_reactivation_email(user_integration).deliver
    end
  end
end