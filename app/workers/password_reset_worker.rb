class PasswordResetWorker
  include Sidekiq::Worker

  def perform(invitation_id, password)
    @invitation = Invitation.find_by_id(invitation_id)
    puts "Sending password reset email...."
    WelcomeUserMailer.password_reset_email(@invitation,password).deliver
    puts "Password reset email sent successfully"
  end
end
