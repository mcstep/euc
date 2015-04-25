class UsersController < ApplicationController
  before_action :require_login

  before_action :require_admin
  skip_before_action :require_admin, only: [:edit_profile]

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  #
  # All GET endpoints are also reachable under
  # /invitations/1/user(/...)
  #

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    authorize @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def edit_profile
    begin
      if current_user.update(edit_profile_params)
        redirect_to dashboard_path, notice: 'Your profile was successfully updated.'
      else
        redirect_to dashboard_path, alert: 'Failed to update your profile.'
      end
    rescue Exception => e
      redirect_to dashboard_path, alert: e.to_s
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if params[:invitation_id].blank?
        @user = User.find(params[:id])
      else
        invitation = Invitation.find(params[:invitation_id])
        @user = User.find_by_invitation_id(invitation.id)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:avatar, :company, :display_name, :email, :total_invitations, :remove_avatar, :title, :username)
    end

    def edit_profile_params
      params.require(:user).permit(:avatar, :company, :display_name, :remove_avatar, :title)
    end

    def require_login
      redirect_to log_in_path, notice: "Please sign in" unless current_user
    end

    def require_admin
      unless current_user && current_user.admin?
        redirect_to dashboard_path, :alert => "Access denied."
      end
    end
end
