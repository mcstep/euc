class SupportRequest
  include ActiveModel::Model

  DEFAULT_EMAIL = 'eucdemohelp@vmware.com'

  attr_accessor :subject, :body, :from

  def assign_attributes(values)
    values.each do |k, v|
      send("#{k}=", v)
    end
  end

  def default_email
    'eucdemohelp@vmware.com'
  end

  def default_subject
    "Support request from #{from.try(:display_name) || 'somebody'} through the EUC Demo Portal"
  end

  def recipient_email
    from.try(:invited_by).try(:email)   ||
      from.try(:profile).try(:support_email)  ||
      DEFAULT_EMAIL
  end

  def send!
    SupportRequestWorker.perform_async(recipient_email, from.email, subject || default_subject, body, from.display_name)
  end
end