class ExpirationWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.unscoped.find(user_id)
    user.expire!
    GeneralMailer.account_expiry_email(user).deliver_now
  end
end