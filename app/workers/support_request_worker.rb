class SupportRequestWorker
  include Sidekiq::Worker

  def perform(recipient, from, subject, body, name)
    WelcomeUserMailer.support_request_email(recipient, from, subject, body, name).deliver
  end
end
