class PasswordResetController < ApplicationController
  def create
    email = params[:email]
    
    @invitation = Invitation.find_by_recipient_email(email)
    if !@invitation.nil? && !@invitation.recipient_username.nil? && (@invitation.recipient_email == email)
      puts "Password reset requested for Email #{email}"
      begin
        response = RestClient.post(url="#{ENV['API_HOST']}/changePassword",payload={:username => @invitation.recipient_username, :email => email}, headers= {:token => ENV["API_KEY"]})
        if response.code == 200
          puts "New Password #{response}"
          PasswordResetWorker.perform_async(@invitation.id, response)
          redirect_to log_in_path, notice: 'Password reset successfully requested. Please check your email for login details.'
        end
      rescue RestClient::Exception => e
        puts "EXCEPTION TRACE: " + e
        redirect_to log_in_path, alert: "Could not reset the user's password"
        return
      rescue Exception => e
        puts e
        redirect_to log_in_path, alert: "Unable to submit password reset request at this time. Please try again later"
        return
      end
    else
      redirect_to log_in_path, alert: "Could not reset the user's password. Invalid username or email"
    end
  end
end
