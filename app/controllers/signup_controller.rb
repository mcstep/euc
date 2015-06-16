class SignupController < ApplicationController
  def index
    redirect_to register_path, :status => 301
  end

  def new
    @invitation = Invitation.new
  end

  def reg_code
    @invitation = Invitation.new
    @reg_code = RegCode.find_by_code(params[:reg_code].downcase)

    puts "Reg#{@reg_code}"

    if @reg_code.nil?
      redirect_to register_path
      return
    end

    render "new" and return
  end

  def create
    @invitation = Invitation.new(invitation_params)
    @reg_code = @invitation.reg_code

    if @reg_code.nil?
      recipient_email = invitation_params[:recipient_email]

      if !recipient_email.blank?
        @domain = Domain.find_by_name(recipient_email.split("@").last.downcase)

        if @domain.nil? || @domain.status != 'active'
          @invitation.errors[:recipient_email] << "Your email domain is currently not supported for registrations."
        end
      end
    end

    puts params

    respond_to do |format|
      if @invitation.save
        SignupWorker.perform_async(@invitation.id)

        flash.now.notice = "Account was successfully requested. Please check your email for login details."
        format.html { render :new }
      else
        if @invitation.invalid?
          flash.now.alert = "Please fill out the form."
        else
          flash.now.alert = "An error happened. Please try again later."
        end

        format.html { render :new }
      end
    end
  end

private
  def invitation_params
    params.require(:invitation).permit(:recipient_email, :recipient_firstname, :recipient_lastname, :recipient_username, :recipient_company, :recipient_title, :region, :reg_code_id)
  end
end
