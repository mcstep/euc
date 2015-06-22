class GeneralMailer < ApplicationMailer
  def welcome_admin_email(user, password)
    @user     = user
    @password = password

    mail(to: @user.email, subject: 'Your Account Information')
  end

  def welcome_basic_email(user, password)
    @user     = user
    @password = password

    mail(to: @user.email, subject: 'Your Account Information')
  end

  def password_reset_email(user, password)
    @user     = user
    @password = password

    mail(to: @user.email, subject: 'Password Reset')
  end
  
  def support_request_email(recipient, email, subject, body, name)
    @recipient = recipient
    @from      = "#{name} <#{email}>"
    @name      = name
    @subject   = subject
    @body      = body

    mail(to: @recipient, subject: @subject, from: @from, reply_to: @from)
  end

  def account_expiry_email(user)
    @user = user

    mail(to: @user.email, subject: 'Account Expiration')
  end

  def account_expiry_reminder_email(user)
    @user = user

    mail(to: @user.email, subject: 'Account Expiration Reminder')
  end

  def account_prolongation_email(user, prolongation)
    @user = user
    @prolongation = prolongation

    mail(to: @user.email, subject: 'Account Extension')
  end

  def portal_upgrades_email(user)
    @user = user

    mail(to: @user.email, subject: 'Demo Portal Upgrades')
  end

  def airwatch_activation_email(user_integration, qr)
    @user     = user_integration.user
    @username = user_integration.directory_username
    @group    = user_integration.integration.airwatch_instance.parent_group_id
    @domain   = user_integration.integration.domain
    @qr       = qr

    mail(to: @user.email, subject: 'AirWatch Account Activation and Enrollment Instructions')
  end

  def airwatch_deactivation_email(user)
    @user = user

    mail(to: @user.email, subject: 'AirWatch Account Deactivation')
  end

  def airwatch_reactivation_email(user)
    @user = user

    mail(to: @user.email, subject: 'AirWatch Account Activation')
  end
end
