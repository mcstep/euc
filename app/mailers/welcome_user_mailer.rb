class WelcomeUserMailer < ActionMailer::Base
  default from: 'noreply@vmwdemo.com'
  default reply_to: 'eucdemohelpp@vmware.com'
 
  def welcome_email(user, password, domain)
    @user = user
    @password = password
    @domain = domain
    mail(to: @user.recipient_email, subject: 'Welcome to VMWDemo')
  end


  def password_reset_email(user, password)
    @user = user
    @password = password
    mail(to: @user.recipient_email, subject: 'Password Reset')
  end
end
