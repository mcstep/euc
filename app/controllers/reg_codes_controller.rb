class RegCodesController < ApplicationController
  before_action :set_reg_code, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  before_action :require_admin

  # GET /reg_codes
  # GET /reg_codes.json
  def index
    @reg_codes = RegCode.all
  end

  # GET /reg_codes/1
  # GET /reg_codes/1.json
  def show
  end

  # GET /reg_codes/new
  def new
    @reg_code = RegCode.new
  end

  # GET /reg_codes/1/edit
  def edit
  end

  # POST /reg_codes
  # POST /reg_codes.json
  def create
    @reg_code = RegCode.new(reg_code_params)

    respond_to do |format|
      if @reg_code.save
        format.html { redirect_to @reg_code, notice: 'Reg code was successfully created.' }
        format.json { render :show, status: :created, location: @reg_code }
      else
        format.html { render :new }
        format.json { render json: @reg_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reg_codes/1
  # PATCH/PUT /reg_codes/1.json
  def update
    respond_to do |format|
      if @reg_code.update(reg_code_params)
        format.html { redirect_to @reg_code, notice: 'Reg code was successfully updated.' }
        format.json { render :show, status: :ok, location: @reg_code }
      else
        format.html { render :edit }
        format.json { render json: @reg_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reg_codes/1
  # DELETE /reg_codes/1.json
  def destroy
    @reg_code.destroy
    respond_to do |format|
      format.html { redirect_to reg_codes_url, notice: 'Reg code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reg_code
      @reg_code = RegCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reg_code_params
      params.require(:reg_code).permit(:code, :valid_from, :valid_to, :status, :registrations, :account_type, :account_validity)
    end

    def require_login
      redirect_to log_in_path unless current_user
    end

    def require_admin
      unless current_user && current_user.admin?
        redirect_to dashboard_path, :alert => "Access denied."
      end
    end
end
