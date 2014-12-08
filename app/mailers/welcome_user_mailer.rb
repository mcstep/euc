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
  
  def support_request_email(recipient, email, subject, body, name)
    @recipient = recipient
    @from = "#{name} <#{email}>"
    @name = name
    @subject = subject
    @body = body
    mail(to: @recipient, subject: @subject, from: @from, reply_to: @from)
  end

  def account_expiry_email(invitation)
    @invitation = invitation
    mail(to: @invitation.recipient_email, subject: 'Account Expiration')
  end

  def account_expiry_reminder_email(invitation)
    @invitation = invitation
    mail(to: @invitation.recipient_email, subject: 'Account Expiration Reminder')
  end

  def account_extension_email(invitation, extension)
    @invitation = invitation
    @extension = extension
    mail(to: @invitation.recipient_email, subject: 'Account Extension')
  end

  def airwatch_user_activation_email(invitation, group, domain, qr)
    @invitation = invitation
    @group = group
    @domain = domain
    @qr = qr
    mail(to: @invitation.recipient_email, subject: 'AirWatch Account Activation and Enrollment Instructions')
  end

  def airwatch_user_deactivation_email(invitation)
    @invitation = invitation
    mail(to: @invitation.recipient_email, subject: 'AirWatch Account Deactivation')
  end

  def airwatch_user_reactivation_email(invitation)
    @invitation = invitation
    mail(to: @invitation.recipient_email, subject: 'AirWatch Account Activation')
  end

  def portal_upgrades_email(invitation)
    @invitation = invitation
    mail(to: @invitation.recipient_email, subject: 'Demo Portal Upgrades')
  end

end
