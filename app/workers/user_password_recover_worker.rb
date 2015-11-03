class UserPasswordRecoverWorker
  include Sidekiq::Worker

  def perform(user_id, password=nil)
    user = User.unscoped.find(user_id)
    password ||= user.update_password
    GeneralMailer.password_recover_email(user, password).deliver_now
  end
end
