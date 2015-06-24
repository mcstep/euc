class SignupController < ApplicationController
  layout 'unauthorized'

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

    puts params

    if @invitation.save
      SignupWorker.perform_async(@invitation.id)

      redirect_to log_in_path, :flash => { :notice => "Account was successfully requested. Please check your email for login details." }
    else
      if @invitation.invalid?
        flash.now.alert = "The data you submitted contains invalid fields. Please correct any errors and try again."
      else
        flash.now.alert = "An error happened. Please try again later."
      end

      respond_to do |format|
        format.html { render :new }
      end
    end
  end

private
  def invitation_params
    params.require(:invitation).permit(:recipient_email, :recipient_firstname, :recipient_lastname, :recipient_username, :recipient_company, :recipient_title, :region, :reg_code_id)
  end
end
