class UserNotifyPasswordChangeWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.unscoped.find(user_id)
    GeneralMailer.password_changed_email(user).deliver_now
  end
end
