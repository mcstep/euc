class SignupWorker
  include Sidekiq::Worker

  def perform(user_id)
    user        = User.find(user_id)
    integration = user.authentication_integration
    username    = integration.username
    directory   = integration.directory
    password    = false

    if integration.directory_not_provisioned?
      response = directory.signup(integration)
      password = response['password']
      integration.update_attributes(username: response['username'], directory_status: :account_created)
    end

    if integration.directory_account_created?
      User::REGIONS.each do |region|
        directory.create_profile(username, region)
      end
      integration.update_attributes(directory_status: :profile_created)
    end

    if integration.directory_profile_created?
      user.profile.directory_groups.each do |group|
        directory.add_group(username, group)
      end
      integration.update_attributes(directory_status: :groups_assigned)
    end

    if integration.directory_groups_assigned?
      directory.sync('dldc')
      integration.update_attributes(directory_status: :provisioned)
    end

    GeneralMailer.welcome_email(user, password || user.update_password).deliver
    DirectoryReplicationWorker.perform_async(directory.id)
  end
end
