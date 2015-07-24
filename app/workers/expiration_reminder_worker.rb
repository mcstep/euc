class ExpirationReminderWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.unscoped.find(user_id)
    GeneralMailer.account_expiry_reminder_email(user).deliver_now
  end
end
