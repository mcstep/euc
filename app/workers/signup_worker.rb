class SignupWorker
  include Sidekiq::Worker

  def perform(user)
    user        = User.find(user) unless user.is_a?(User)
    integration = user.authentication_integration
    username    = integration.username
    directory   = integration.directory
    password    = false

    UserSession.tag_user(user) do
      if integration['directory_status'] < UserIntegration.directory_statuses[:account_created]
        response = directory.signup(integration)
        password = response['password']
        integration.update_attributes(username: response['username'], directory_status: :account_created)
      end

      if integration['directory_status'] < UserIntegration.directory_statuses[:provisioned]
        user.profile.directory_groups.each do |group|
          directory.add_group(username, group)
        end
        directory.sync(user.profile.group_region) if user.profile.directory_groups.any?
        integration.update_attributes(directory_status: :provisioned)
      end

      GeneralMailer.welcome_email(user, password || user.update_password).deliver_now
      DirectoryReplicationWorker.perform_async(directory.id)
    end
  end
end
