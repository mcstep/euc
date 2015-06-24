class SessionsController < ApplicationController
  layout 'unauthorized'

  def new
  end

  def create
    if params[:username].empty? || params[:password].empty?
      flash.now.alert = "Username or password cannot be blank"
      render "new" and return
    end

    begin
      username = (params[:username][/[^@]+/]).downcase

      inv_for_user = Invitation.find_by_recipient_username(username)

      if inv_for_user.nil?
        flash.now.alert = "Invalid username or password"
        render "new"
        return
      end

      response = RestClient.post(url="#{ENV['API_HOST']}/authenticate",payload={:username => username, :password => params[:password]}, headers= {:token => ENV["API_KEY"]})
      puts response
      if response.code == 200
        user_json = JSON.parse response
        puts "Auth response #{user_json}"
        user = User.authenticate(username, params[:password])

        if user
          # Update the user's attributes, in case they've been updated in the AD
          user.email = user_json['email'] if user_json['email'] != nil
          user.display_name = user_json['name'] if user_json['name'] != nil
          user.title = user_json['title'] if user_json['title'] != nil
          user.company = user_json['company'] if user_json['company'] != nil
          user.save
          session[:user_id] = user.id
          redirect_to dashboard_path, :notice => "Logged in!"
        else
          usr = User.new
          usr.username = user_json['username']
          usr.email = user_json['email'] if user_json['email'] != nil
          usr.display_name = user_json['name'] if user_json['name'] != nil
          usr.title = user_json['title'] if user_json['title'] != nil
          usr.company = user_json['company'] if user_json['company'] != nil
          usr.invitation_limit = 5

          # find the corresponding invitation and check if the user signed up with a reg_code
          inv_for_user = Invitation.find_by_recipient_username(usr.username)

          if inv_for_user.nil?
            flash.now.alert = "Invitation not found"
            render "new"
            return
          end

          usr.invitation_id = inv_for_user.id;

          if !inv_for_user.reg_code_id.nil?
            reg_code = RegCode.find_by_id(inv_for_user.reg_code_id)
            #TODO: NUll check for reg_code
            usr.role =  reg_code.account_type
          else
            # If the user is in one of the whitelisted domains -> assign a vip role
            if is_domain_whitelisted?(usr.email.split("@").last)
              usr.role = 'vip'
            else
              usr.role = 'user'
            end
          end

          usr.save!

          puts "User ID#{usr.id}"
          session[:user_id] = usr.id
          redirect_to dashboard_path, :notice => "Logged in!"
        end
      else
        flash.now.alert = "Invalid username or password"
        render "new"
      end
     rescue RestClient::Exception => e
       puts e
       flash.now.alert = "Invalid username or password"
       render "new"
     rescue Exception => e
       puts e
       flash.now.alert = "Unable to login at this time. Please try again later"
       render "new"
     end

    #session[:user_id] = 1
    #redirect_to root_path, :notice => "Logged in!"
  end

  def destroy
    session[:user_id] = nil
    session[:impersonator_id] = nil
    redirect_to root_path, :notice => "Logged out!"
  end
end
