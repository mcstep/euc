class UserVerifyWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    user.transaction do
      nexmo = Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
      nexmo.send_message(from: 'VMWare', to: user.phone, text: "Token: #{user.verification_token}")
    end
  end
end