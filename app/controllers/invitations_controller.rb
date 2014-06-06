class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  # GET /invitations
  # GET /invitations.json
  def index
    @invitations = Invitation.all
  end

  # GET /invitations/1
  # GET /invitations/1.json
  def show
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations
  # POST /invitations.json
  def create
    @invitation = Invitation.new(invitation_params)
    @invitation.sender = current_user
    @invitation.expires_at = (Time.now + 1.month) 

    respond_to do |format|
      if @invitation.save
        SignupWorker.perform_async(@invitation.id)
        format.html { redirect_to dashboard_path, notice: 'Invitation was successfully created.' }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :new }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitations/1
  # PATCH/PUT /invitations/1.json
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to @invitation, notice: 'Invitation was successfully updated.' }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1
  # DELETE /invitations/1.json
  def destroy
    #Remove the AD account
    account_removed = false
    begin
      #response = RestClient.post 'http://75.126.198.236:8080/unregister', :username => @invitation.recipient_username
      response = RestClient.post(url='http://75.126.198.236:8080/unregister',payload={:username => @invitation.recipient_username}, headers= {:token => ENV["API_KEY"]})
      if response.code == 200
        @invitation.destroy
        account_removed = true
      end
    rescue RestClient::Exception
      redirect_to dashboard_path, alert: "Could not delete the user's account"
      return
    rescue Exception
      redirect_to dashboard_path, alert: "Unable to delete the user's account at this time. Please try again later"
      return
    end

    #Update the invitation limit
    @user = @invitation.sender
    @user.invitation_limit += 1
    @user.save!

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: 'Invitation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitation_params
      params.require(:invitation).permit(:sender_id, :recipient_email, :token, :recipient_username, :recipient_firstname, :recipient_lastname, :recipient_title, :recipient_company)
    end

    def require_login
      redirect_to log_in_path, notice: "Please sign in" unless current_user
    end
end
