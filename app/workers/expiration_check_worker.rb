class ExpirationCheckWorker
  include Sidekiq::Worker

  def perform(send_reminders=true)
    User.expiring_soon.each{|u| ExpirationReminderWorker.perform_async(u.id)} if send_reminders
    User.expired.each{|u| ExpirationWorker.perform_async(u.id)}
  end
end
