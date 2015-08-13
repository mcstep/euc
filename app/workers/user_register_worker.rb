class UserRegisterWorker
  include Sidekiq::Worker

  def perform(user, desired_password=nil)
    user        = User.find(user) unless user.is_a?(User)
    integration = user.authentication_integration
    username    = integration.username
    directory   = integration.directory
    password    = false

    User::Session.tag_user(user) do
      if integration['directory_status'] < UserIntegration.directory_statuses[:account_created]
        response = directory.signup(integration)
        password = response['password'] if desired_password.blank?

        integration.username = response['username']
        integration.directory_status = :account_created
        integration.save!
      end

      if integration['directory_status'] < UserIntegration.directory_statuses[:provisioned]
        user.update_password(desired_password) unless desired_password.blank?

        user.profile.directory_groups.each do |group|
          directory.add_group(username, group)
        end
        directory.sync(user.profile.group_region.blank? ? 'dldc' : user.profile.group_region)

        integration.directory_status = :provisioned
        integration.save!
      end

      # In case we are re-running and desired_password is empty
      password ||= user.update_password if desired_password.blank?

      GeneralMailer.welcome_email(user, password).deliver_now
      DirectoryReplicateWorker.perform_async(directory.id)
    end
  end
end
