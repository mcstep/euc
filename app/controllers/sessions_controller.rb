class SessionsController < ApplicationController

def new
end

def create
  begin
    response = RestClient.post 'http://75.126.198.236:8080/authenticate', :username => "#{params[:username]}@vmwdemo.int", :password => params[:password], :token => 'xQAt7e39l44EAP1D14cv5qXXjg0D904w'
    if response.code == 200
      user_json = JSON.parse response
      user = User.authenticate(params[:username], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to root_url, :notice => "Logged in!"
      else
        usr = User.new
        usr.username = user_json['username']
	usr.email = user_json['email'] if user_json['email'] != nil
	usr.invitation_limit = 5 
        usr.save!
	
	puts "User ID#{usr.id}"
        session[:user_id] = usr.id
        redirect_to root_url, :notice => "Logged in!"
     end
   else
      flash.now.alert = "Invalid email or password"
      render "new"
   end

   rescue RestClient::Exception
     flash.now.alert = "Invalid email or password"
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
