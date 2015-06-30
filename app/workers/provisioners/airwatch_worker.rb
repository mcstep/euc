module Provisioners
  class AirwatchWorker < ProvisionerWorker
    def provision(user_integration)
      user_integration.airwatch.provision
      instance = user_integration.integration.airwatch_instance

      user_integration.airwatch_group_id = AirwatchGroup.instantiate(user_integration)
      user_integration.airwatch_user_id  = instance.add_user(user_integration.directory_username)['Value']
      add_group user_integration, instance.group_name, instance.group_region

      GeneralMailer.airwatch_activation_email(user_integration).deliver
      user_integration.save!
    end

    def deprovision(user_integration)
      instance = user_integration.integration.airwatch_instance

      instance.deactivate(user_integration.airwatch_user_id)
      sleep 5 # Fix this. Currently have to do this because the AirWatch API can't handle deletion immediately after deactivation :(
      instance.delete(user_integration.airwatch_user_id)
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