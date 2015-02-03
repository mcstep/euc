class SignupController < ApplicationController
  def new
  end

  def reg_code
    code = params[:reg_code].downcase
    @reg_code = RegCode.find_by_code(code)
    puts "Reg#{@reg_code}"
    if @reg_code.nil?
      redirect_to register_path
      return
    end
    render "new" and return
  end

  def create
    if params[:email].empty? || params[:firstname].empty? || params[:lastname].empty? || params[:company].empty? || params[:title].empty?
      flash.now.alert = "One or more fields are invalid"
      render "new" and return
    end

    user_domain = params[:email].split("@").last.downcase 
    @domain = Domain.find_by_name(user_domain)	
    
    reg_code_text = params[:reg_code_text]
    reg_code = nil
    if !reg_code_text.nil?
      reg_code = RegCode.find_by_code(reg_code_text)
    end

    if reg_code != nil
      current_reg_count = Invitation.where("reg_code_id = #{reg_code.id}").count
      if reg_code.status == false || (!(reg_code.valid_from..reg_code.valid_to).cover?(Time.now)) || (current_reg_count >= reg_code.registrations)
        flash.now.alert = "Sorry! The registration code you entered is no longer valid"
        redirect_to registration_code_signup_path(reg_code.code), :flash => { :error => "Sorry! The registration code you entered is no longer valid" }
        return
        #render "new" and return
      end
    else
      if @domain.nil? || @domain.status != 'active'
        flash.now.alert = "Sorry! We do not support your email domain for registration yet"
        render "new" and return
      end
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
    @invitation.airwatch_trial = true 
    @invitation.google_apps_trial = true
    @invitation.reg_code_id = reg_code.id unless reg_code.nil?

    # Check for whitespaces and remove them
    if @invitation.recipient_username.blank?
      @invitation.recipient_username = nil
    end

    # update the expires_at if the account was created using a reg code
    if !reg_code.nil?
      num_days = reg_code.account_validity
      @invitation.expires_at = (Time.now + num_days.days)
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
