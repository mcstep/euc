class ProvisionerWorker
  include Sidekiq::Worker

  attr_reader :user_integration

  def self.[](service)
    "Provisioners::#{service.camelize}Worker".constantize
  end

  def self.service
    @service ||= name.gsub('Provisioners::', '').gsub('Worker', '').underscore
  end

  %w(provision deprovision revoke resume cleanup).each do |action|
    define_singleton_method "#{action}_async" do |user_integration_id|
      perform_async(user_integration_id, action)
    end
  end

  def perform(user_integration, action)
    user_integration  = UserIntegration.with_deleted.find(user_integration) unless user_integration.is_a?(UserIntegration)
    @user_integration = user_integration

    User::Session.tag_user(@user) do
      send action
    end
  end

  # Own actions
  def cleanup
    wait_until !@user_integration.applying? do
      Integration::SERVICES.each do |s|
        @user_integration[s].deprovision
        @user_integration.save!
      end
    end
  end

  # Helpers
  def instance
    @instance ||= @user_integration.integration.send(:"#{self.class.service}_instance")
  end

  def user
    @user ||= @user_integration.user
  end

  def wait_until(condition, timeout=1.minute, &block)
    if condition
      yield
    else
      self.class.perform_in timeout, @user_integration.id, caller[0][/`.*'/][1..-2]
    end
  end

  def add_group(group_name, group_region)
    @user_integration.directory.add_group(@user_integration.username, group_name, @user_integration.integration.domain)
    @user_integration.directory.replicate
    @user_integration.directory.sync(group_region)
  end

  def remove_group(group_name, group_region)
    @user_integration.directory.remove_group(@user_integration.username, group_name, @user_integration.integration.domain)
    @user_integration.directory.replicate
    @user_integration.directory.sync(group_region)
  end
end