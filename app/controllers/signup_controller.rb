class SignupController < ApplicationController
  def new
  end

  def create
    account_create = false
    @invitation = Invitation.new
    @invitation.recipient_email = params[:email]
    @invitation.recipient_firstname = params[:firstname]
    @invitation.recipient_lastname = params[:lastname]
    @invitation.recipient_company = params[:company]
    @invitation.recipient_title = params[:title]
    @invitation.expires_at = (Time.now + 1.year)

    #if params[:email].split("@").last == "gmail.com"
    # account_create= true
    #end

    account_create= true
  
    respond_to do |format|
      if account_create
        @invitation.save
        SignupWorker.perform_async(@invitation.id)
        format.html { redirect_to root_path, notice: 'Account was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end
end
