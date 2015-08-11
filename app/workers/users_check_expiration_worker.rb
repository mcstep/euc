class UsersCheckExpirationWorker
  include Sidekiq::Worker

  def perform(send_reminders=true)
    User.expiring_soon.each{|u| UserNotifyExpirationWorker.perform_async(u.id)} if send_reminders
    User.expired.each{|u| UserExpireWorker.perform_async(u.id)}
  end
end
