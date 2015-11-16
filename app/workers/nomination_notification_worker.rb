class NominationNotificationWorker
  include Sidekiq::Worker

  def perform(nomination_id)
    GeneralMailer.nomination_notify_email(Nomination.find nomination_id).deliver_now
  end
end
