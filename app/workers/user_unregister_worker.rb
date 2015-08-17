class UserUnregisterWorker
  include Sidekiq::Worker

  def perform(user)
    user        = User.with_deleted.find(user) unless user.is_a?(User)
    integration = user.authentication_integration
    username    = integration.username
    directory   = integration.directory

    User::Session.tag_user(user) do
      directory.unregister username, integration.integration.domain
    end

    GeneralMailer.account_expiry_email(user).deliver_now
  end
end
