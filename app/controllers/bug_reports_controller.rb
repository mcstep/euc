class BugReportsController < ApplicationController
  skip_after_action :verify_authorized

  def create
    @bug_report.assign_attributes(params[:bug_report])
    @bug_report.send!
    redirect_to root_path, notice: I18n.t('flash.bug_report_sent')
  end
end
