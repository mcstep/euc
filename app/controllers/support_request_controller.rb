class SupportRequestController < ApplicationController
  def create
    recipient = params[:recipient]
    subject = params[:subject]
    body = params[:notes]
    puts "Recipient " + recipient
    SupportRequestWorker.perform_async(recipient, current_user.email, subject, body, current_user.display_name)
    redirect_to dashboard_path, notice: 'Support request sent successfully.'
  end
end
