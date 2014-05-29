class SignupController < ApplicationController
  def new
  end

  def create
    begin
      response = RestClient.post 'http://75.126.198.236:8080/signup', :fname => params[:firstname], :lname => params[:lastname], :uname => 'demo.user', :org => params[:company], :email => params[:email], :title => params[:title]
      if response.code == 200
        json_body = JSON.parse response
        puts json_body
        account_created = true
      end
    rescue => e
      #errors[:base] << "Sorry! Could not contact the AD Server at this time. Please try again later!"
      logger.error "error contacting AD server"
      puts e
    end

    respond_to do |format|
      if account_created
        format.html { redirect_to root_path, notice: 'Account was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end
end
