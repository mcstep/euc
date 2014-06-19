class WelcomeUserMailer < ActionMailer::Base
  default from: %("VMware EUC Demo Portal" <noreply@vmwdemo.com>)
  default reply_to: 'eucdemohelpp@vmware.com'
 
  def welcome_email(user, password, domain)
    @user = user
    @password = password
    @domain = domain
    mail(to: @user.recipient_email, subject: 'Your Account Information')
  end

  def welcome_email_invited(invitation, password, domain)
    @invitation = invitation
    @password = password
    @domain = domain
    mail(to: @invitation.recipient_email, subject: 'Your Account Information')
  end

  def password_reset_email(user, password)
    @user = user
    @password = password
    mail(to: @user.recipient_email, subject: 'Password Reset')
  end
  
  def support_request_email(recipient, from, subject, body)
    @recipient = recipient
    @from = from
    @subject = subject
    @body = body
    mail(to: @recipient, subject: 'Support Request: ' + @subject, from: @from, reply_to: @from)
  end
end
