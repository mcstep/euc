module Provisioners
  class BoxWorker < ProvisionerWorker
    def provision
      wait_until user.provisioned? && instance.access_token.present? do
        user_integration.transaction do
          user_integration.box.complete_application

          add_group(instance.group_name, instance.group_region) if instance.group_name

          user_integration.box_user_id = instance.register(
            user_integration.email,
            user.display_name
          )
          user_integration.save!
        end
      end
    end

    def revoke
      wait_until instance.access_token.present? do
        user_integration.transaction do
          user_integration.box.complete_application
          user_integration.box_user_id = nil
          user_integration.save!

          remove_group(instance.group_name, instance.group_region) if instance.group_name
          instance.unregister(user_integration.box_user_id)
        end
      end
    end

    def resume
      provision
    end

    def deprovision
      user_integration.box.complete_application
      user_integration.save!
    end
  end
end