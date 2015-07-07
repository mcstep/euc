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

  def perform(user_integration_id, action)
    user_integration = UserIntegration.find(user_integration_id)
    send action, user_integration
  end

  def revoke(user_integration)
    deprovision(user_integration)
  end

  def resume(user_integration)
    provision(user_integration)
  end

  def cleanup(user_integration)
  end

  def add_group(user_integration, group_name, group_region)
    user_integration.directory.add_group(user_integration.directory_username, group_name)
    user_integration.directory.sync(group_region)
  end

  def remove_group(user_integration, group_name, group_region)
    user_integration.directory.remove_group(user_integration.directory_username, group_name)
    user_integration.directory.sync(group_region)
  end
end