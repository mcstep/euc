class WelcomeUserMailer < ActionMailer::Base
  default from: 'test.vmwdemo@gmail.com'
 
  def welcome_email(user, password)
    @user = user
    @password = password
    mail(to: @user.recipient_email, subject: 'Welcome to VMWDemo')
  end
end
