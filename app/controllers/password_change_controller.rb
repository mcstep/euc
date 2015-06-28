class PasswordChangeController < ApplicationController
  def check_password
   begin
    username = (current_user.username).downcase
    response = RestClient.post( url="#{ENV['API_HOST']}/authenticate",
                                payload={ :username => username, 
                                          :password => params[:current_password],
                                          :domain_suffix => get_domain_suffix(current_user.email),
                                        }, 
                                headers= {:token => ENV["API_KEY"]})
    puts response
    render :json => (response.code == 200)
   rescue Exception => e
     render :json => false
   end
  end

  def change_password
    password = params[:new_password]

   begin
    username = (current_user.username).downcase
    response = RestClient.post( url="#{ENV['API_HOST']}/authenticate",
                                payload={ :username => username, 
                                          :password => params[:current_password], 
                                          :domain_suffix => get_domain_suffix(current_user.email),
                                          },
                                headers= {:token => ENV["API_KEY"]})
    puts response
      if response.code != 200
        puts e
        redirect_to dashboard_path, alert: "Invalid current password. Please enter the correct password and try again"
        return
      end
   rescue Exception => e
     puts e
     redirect_to dashboard_path, alert: "Unable to change user password at this time. Please try again later"
     return
   end

    @invitation = Invitation.find(current_user.invitation_id)
    if !@invitation.nil? && !@invitation.recipient_username.nil? && (@invitation.recipient_email == current_user.email)
      puts "Password change requested for Username #{current_user.username}"
      begin
        response = RestClient.post( url="#{ENV['API_HOST']}/changeUserPassword",
                                    payload={ :username => current_user.username, 
                                              :password => password,
                                              :domain_suffix => get_domain_suffix(current_user.email),
                                            }, 
                                    headers= {:token => ENV["API_KEY"]})
        if response.code == 200
          puts "New Password #{response}"
          PasswordResetWorker.perform_async(@invitation.id, response)
          redirect_to dashboard_path, notice: 'Password reset successfully requested. Please check your email for login details.'
        end
      rescue RestClient::Exception => e
        puts e
        redirect_to dashboard_path, alert: "Could not change the user's password"
        return
      rescue Exception => e
        puts e
        redirect_to dashboard_path, alert: "Unable to change user password at this time. Please try again later"
        return
      end
    else
      redirect_to dashboard_path, alert: "Could not change the user's password. Please try again later"
    end
  end
end
