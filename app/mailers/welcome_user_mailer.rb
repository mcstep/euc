class WelcomeUserMailer < ActionMailer::Base
  default from: 'noreply@vmwdemo.com'
  default reply_to: 'eucdemohelpp@vmware.com'
 
  def welcome_email(user, password)
    @user = user
    @password = password
    mail(to: @user.recipient_email, subject: 'Welcome to VMWDemo')
  end
end
