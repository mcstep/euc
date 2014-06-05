class SignupController < ApplicationController
  def new
  end

  def create
    if params[:email].empty? || params[:firstname].empty? || params[:lastname].empty? || params[:company].empty? || params[:title].empty?
      flash.now.alert = "One or more fields are invalid"
      render "new" and return
    end

    account_create = false
    @invitation = Invitation.new
    @invitation.recipient_email = params[:email]
    @invitation.recipient_firstname = params[:firstname]
    @invitation.recipient_lastname = params[:lastname]
    @invitation.recipient_company = params[:company]
    @invitation.recipient_title = params[:title]
    @invitation.expires_at = (Time.now + 1.year)
    @invitation.region = params[:region]

    user_domain = params[:email].split("@").last 
    @domain = Domain.find_by_name(user_domain)	
    if !@domain.nil? && @domain.status == 'active'
     account_create= true
    end

    #account_create= true
    puts params
    respond_to do |format|
      if account_create && @invitation.save
        SignupWorker.perform_async(@invitation.id)
        format.html { redirect_to dashboard_path, notice: 'Account was successfully requested. Please check your email for login details.' }
      else
	flash.now.alert = "One or more fields are invalid"
        format.html { render :new }
      end
    end
  end
end
