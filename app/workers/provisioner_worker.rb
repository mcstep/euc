class ProvisionerWorker
  include Sidekiq::Worker

  def self.[](service)
    "Provisioners::#{service.camelize}Worker".constantize
  end

  %w(provision deprovision revoke resume cleanup).each do |action|
    define_singleton_method "#{action}_async" do |user_integration_id|
      perform_async(user_integration_id, action)
    end
  end

  def perform(user_integration, action)
    user_integration  = UserIntegration.find(user_integration) unless user_integration.is_a?(UserIntegration)
    @user_integration = user_integration
    @user             = @user_integration.user

    User::Session.tag_user(@user) do
      send action
    end
  end

  def wait_until(condition, &block)
    if condition
      yield
    else
      self.class.perform_in 1.minute, @user_integration.id, caller[0][/`.*'/][1..-2]
    end
  end

  def deprovision
    wait_until(!@user_integration.applying?){ revoke }
  end

  def resume
    provision
  end

  def cleanup
  end

  def add_group(group_name, group_region)
    @user_integration.directory.add_group(@user_integration.username, group_name)
    @user_integration.directory.sync(group_region)
  end

  def remove_group(group_name, group_region)
    @user_integration.directory.remove_group(@user_integration.username, group_name)
    @user_integration.directory.sync(group_region)
  end
end