class UserRequestsAggregatorWorker
  include Sidekiq::Worker

  def perform
    UserRequest.transaction do
      User.rotate_requests_logs do |entries|
        entries.group_by{|x| x[1].change(min: 0)}.each do |datetime, entries|
          existing = UserRequest.where(date: datetime.to_date, hour: datetime.hour)
          entries.group_by{|x| x[2]}.each do |ip, entries|
            if attempt = existing.find{|x| x.ip == ip}
              attempt.quantity += entries.length
              attempt.save!
            else
              UserRequest.create!(date: datetime.to_date, hour: datetime.hour, ip: ip, quantity: entries.length)
            end
          end
        end
      end
    end
  end
end