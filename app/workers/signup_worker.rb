class SignupWorker
  include Sidekiq::Worker

  def perform(user_id)
    user        = User.find(user_id)
    integration = user.authentication_integration
    directory   = integration.directory
    password    = false

    if integration.directory_not_provisioned?
      response = directory.signup(integration)
      password = response['password']
      integration.update_attributes(username: response['username'], directory_status: :account_created)
    end

    if integration.directory_account_created? && !Rails.env.development?
      directory.replicate
      integration.update_attributes(directory_status: :ad_replicated)
    end

    if (integration.directory_account_created? && Rails.env.development?) || integration.directory_ad_replicated?
      User::REGIONS.each do |region|
        directory.create_profile(integration.directory_username, region)
      end
      integration.update_attributes(directory_status: :profile_created)
    end

    if integration.directory_profile_created?
      directory.sync(integration.directory_username, user.home_region)
      integration.update_attributes(directory_status: :provisioned)
    end

    password ||= user.update_password

    if user.basic?
      GeneralMailer.welcome_basic_email(user, password)
    else
      GeneralMailer.welcome_admin_email(user, password)
    end
  end
end
