class UserVerifyWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    user.transaction do
      self.verification_token = ReadableToken.generate
      self.save!

      if user.phone
        nexmo = Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
        nexmo.send_message(from: 'VMWare', to: user.phone, text: "Token: #{user.verification_token}")
      else
        GeneralMailer.verification_email(user.verification_token).deliver
      end
    end
  end
end