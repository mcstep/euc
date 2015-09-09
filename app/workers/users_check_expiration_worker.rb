class UsersCheckExpirationWorker
  include Sidekiq::Worker

  def perform
    handle_expiring(async: true)
    handle_expired(async: true)
  end

  def handle_expiring(async: false)
    User.expiring_soon.each do |u|
      if async
        UserNotifyExpirationWorker.perform_async(u.id)
      else
        UserNotifyExpirationWorker.new.perform(u.id)
      end
    end
  end

  def handle_expired(async: false)
    User.expired.each do |u|
      if async
        UserExpireWorker.perform_async(u.id)
      else
        UserExpireWorker.new.perform(u.id)
      end
    end
  end
end
