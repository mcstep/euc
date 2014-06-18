class SupportRequestWorker
  include Sidekiq::Worker

  def perform(recipient, from, subject, body)
    puts "Sending support request email....#{recipient}"
    WelcomeUserMailer.support_request_email(recipient, from, subject, body).deliver
    puts "Support request email sent successfully"
  end
end
