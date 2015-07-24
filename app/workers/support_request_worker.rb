class SupportRequestWorker
  include Sidekiq::Worker

  def perform(recipient, from, subject, body, name)
    GeneralMailer.support_request_email(recipient, from, subject, body, name).deliver_now
  end
end
