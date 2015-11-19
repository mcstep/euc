class GeneralMailer < ApplicationMailer
  def welcome_email(user, password)
    @user     = user
    @password = password
    template  = user.basic? ? 'welcome_basic_email' : 'welcome_admin_email'

    mail(to: @user.email, subject: 'Your Account Information', template_name: template)
  end

  def password_recover_email(user, password)
    @user     = user
    @password = password

    mail(to: @user.email, subject: 'Password Reset')
  end
  
  def password_changed_email(user)
    @user = user

    mail(to: @user.email, subject: 'Password Changed')
  end

  def support_request_email(recipient, email, subject, body, name)
    @recipient = recipient
    @from      = "#{name} <#{email}>"
    @name      = name
    @subject   = subject
    @body      = body
    @cc        = ENV['SUPPORT_REQUEST_CC_EMAIL']

    mail(to: @recipient, subject: @subject, from: @from, reply_to: @from, cc: @cc)
  end

  def account_expiry_email(user)
    @user = user

    mail(to: @user.email, subject: 'Account Expiration')
  end

  def account_expiry_reminder_email(user)
    @user = user

    mail(to: @user.email, subject: 'Account Expiration Reminder')
  end

  def directory_prolongation_email(prolongation)
    @prolongation = prolongation
    @user         = prolongation.user_integration.user

    mail(to: @prolongation.user_integration.user.email, subject: 'Account Extension')
  end

  def portal_upgrades_email(user)
    @user = user

    mail(to: @user.email, subject: 'Demo Portal Upgrades')
  end

  def airwatch_activation_email(user_integration)
    instance  = user_integration.integration.airwatch_instance
    @user     = user_integration.user
    @username = user_integration.username
    @group    = user_integration.airwatch_group.text_id
    @domain   = user_integration.integration.domain
    path      = Rails.root.join 'tmp', Dir::Tmpname.make_tmpname('qr', nil)

    begin
      RQRCode::QRCode.new(
        "https://awagent.com/Home/Welcome?gid=#{user_integration.airwatch_group.text_id}&serverurl=#{instance.host}",
        size: 10
      ).to_img.resize(200, 200).save(path)

      result = Cloudinary::Uploader.upload(path)
    ensure
      File.delete(path) if File.exist?(path)
    end

    @qr = result['url']

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

  def verification_email(token)
    @token = token

    mail(to: @user.email, subject: 'Verification Code')
  end

  def blue_jeans_removal_email(to, user_integration)
    @user_integration = user_integration

    mail(to: to, subject: 'VMWare Testdrive Portal User Removal')
  end

  def nomination_notify_email(nomination)
    @nomination = nomination

    mail(to: ENV['NOMINATION_NOTIFIY_TO'], subject: "#{nomination.company_name} nominated")
  end

  def bug_report_email(recipient, from, subject, body)
    @body = body

    mail(to: recipient, from: from, reply_to: from, subject: subject)
  end
end
