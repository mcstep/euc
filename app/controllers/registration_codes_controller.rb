class RegistrationCodesController < ApplicationController
  def index
    authorize :registration_code
    @registration_codes = RegistrationCode.all
  end

  def show
    authorize @registration_code = RegistrationCode.find(params[:id])
  end

  def new
   authorize @registration_code = RegistrationCode.new
  end

  def edit
    authorize @registration_code = RegistrationCode.find(params[:id])
  end

  def create
    authorize @registration_code = RegistrationCode.new
    @registration_code.assign_attributes(permitted_attributes(@registration_code))

    if @registration_code.save
      redirect_to @registration_code
    else
      render :new
    end
  end

  def update
    authorize @registration_code = RegistrationCode.find(params[:id])

    if @registration_code.update_attributes(permitted_attributes(@registration_code))
      redirect_to @registration_code
    else
      render :edit
    end
  end

  def destroy
    authorize @registration_code = RegistrationCode.find(params[:id])
    @registration_code.destroy

    redirect_to action: :index
  end
end
