class BugReport
  include ActiveModel::Model

  attr_accessor :product, :body, :from

  def assign_attributes(values)
    values.each do |k, v|
      send("#{k}=", v)
    end
  end

  def default_subject
    "User #{from.email} just reported an issue with #{product}"
  end

  def recipient_email
    ENV['BUG_REPORT_TO']
  end

  def send!
    BugReportWorker.perform_async(recipient_email, from.email, default_subject, body)
  end
end