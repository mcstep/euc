class SignupController < ApplicationController
  def index
    redirect_to register_path, :status => 301
  end

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
    alerts = [];

    if params[:email].blank?
      alerts << "Please enter a valid email address."
    end

    if params[:firstname].blank?
      alerts << "Please enter a valid firstname."
    end

    if params[:lastname].blank?
      alerts << "Please enter a valid lastname."
    end

    if params[:company].blank?
      alerts << "Please enter a valid company."
    end

    if params[:title].blank?
      alerts << "Please enter a valid title."
    end

    if alerts.blank?
      user_domain = params[:email].split("@").last.downcase
      @domain = Domain.find_by_name(user_domain)

      reg_code_text = params[:reg_code_text]
      reg_code = nil

      if !reg_code_text.blank?
        reg_code = RegCode.find_by_code(reg_code_text)
      end

      if !reg_code.nil?
        current_reg_count = Invitation.where(reg_code_id: reg_code.id).count

        if reg_code.status == false || (!(reg_code.valid_from..reg_code.valid_to).cover?(Time.now)) || (current_reg_count >= reg_code.registrations)
          redirect_to registration_code_signup_path(reg_code.code), :flash => { :alert => "Sorry! The registration code you entered is no longer valid" }
          return
        end
      else
        if @domain.nil? || @domain.status != 'active'
          alerts << "Your email domain is currently not supported for registration."
        end
      end
    end

    if !alerts.blank?
      flash.now.alert = alerts;
      render "new"
      return
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

    puts params

    respond_to do |format|
      if @invitation.save
        SignupWorker.perform_async(@invitation.id)

        flash.now.notice = "Account was successfully requested. Please check your email for login details."
        format.html { render :new }
      else
        flash.now.alert = "An error happened. Please try again later."
        format.html { render :new, :status => 500 }
      end
    end
  end
end
