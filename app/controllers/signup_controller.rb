class SignupController < ApplicationController
  def new
  end

  def create
    if params[:email].empty? || params[:firstname].empty? || params[:lastname].empty? || params[:company].empty? || params[:title].empty?
      flash.now.alert = "One or more fields are invalid"
      render "new" and return
    end

    user_domain = params[:email].split("@").last.downcase 
    @domain = Domain.find_by_name(user_domain)	
    if @domain.nil? || @domain.status != 'active'
      flash.now.alert = "Sorry! We do not support your email domain for registration yet"
      render "new" and return
    end

    @invitation = Invitation.new
    @invitation.recipient_email = params[:email].downcase
    @invitation.recipient_firstname = params[:firstname]
    @invitation.recipient_lastname = params[:lastname]
    @invitation.recipient_company = params[:company]
    @invitation.recipient_title = params[:title]
    @invitation.expires_at = (Time.now + 1.year)
    @invitation.region = params[:region]
    @invitation.recipient_username = params[:username]
    @invitation.airwatch_trial = false #Yes, by design for now
    @invitation.google_apps_trial = false #Yes, by design for now

    # Check for whitespaces and remove them
    if @invitation.recipient_username.blank?
      @invitation.recipient_username = nil
    end

    account_create= true
    puts params
    respond_to do |format|
      if account_create && @invitation.save
        SignupWorker.perform_async(@invitation.id)
	flash.now.notice = "Account was successfully requested. Please check your email for login details."
        format.html { render :new }
      else
	flash.now.alert = "One or more fields are invalid"
        format.html { render :new }
      end
    end
  end
end
