class BugReportWorker
  include Sidekiq::Worker

  def perform(recipient, from, subject, body)
    GeneralMailer.bug_report_email(recipient, from, subject, body).deliver_now
  end
end
