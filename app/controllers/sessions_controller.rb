class SessionsController < ApplicationController

def new
end

def create
  if params[:username].empty? || params[:password].empty?
    flash.now.alert = "Username or password cannot be blank"
    render "new" and return
  end

  begin
    response = RestClient.post 'http://75.126.198.236:8080/authenticate', :username => "#{params[:username]}@vmwdemo.int", :password => params[:password], :token => 'xQAt7e39l44EAP1D14cv5qXXjg0D904w'
    if response.code == 200
      user_json = JSON.parse response
      puts "Auth response #{user_json}"
      user = User.authenticate(params[:username], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to dashboard_path, :notice => "Logged in!"
      else
        usr = User.new
        usr.username = user_json['username']
	usr.email = user_json['email'] if user_json['email'] != nil
	usr.display_name = user_json['name'] if user_json['name'] != nil    
	usr.invitation_limit = 5 
        # If the user is in one of the whitelisted domains -> assign a vip role
        if usr.email.split("@").last == "vmware.com"
         usr.role = 'vip'
        else
         usr.role = 'user'
        end
        usr.save!
	
	puts "User ID#{usr.id}"
        session[:user_id] = usr.id
        redirect_to root_url, :notice => "Logged in!"
     end
   else
      flash.now.alert = "Invalid username or password"
      render "new"
   end

   rescue RestClient::Exception
     flash.now.alert = "Invalid username or password"
     render "new"
   end

  #session[:user_id] = 1
  #redirect_to root_path, :notice => "Logged in!"
end

def destroy
  session[:user_id] = nil
  redirect_to root_path, :notice => "Logged out!"
end


end
