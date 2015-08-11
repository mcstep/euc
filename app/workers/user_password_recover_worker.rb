class UserPasswordRecoverWorker
  include Sidekiq::Worker

  def perform(user_id, password)
    user = User.unscoped.find(user_id)
    GeneralMailer.password_recover_email(user, password).deliver_now
  end
end
