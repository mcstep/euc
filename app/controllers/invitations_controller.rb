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

    #Create the AD account
    account_created = false
    begin
      response = RestClient.post 'http://75.126.198.236:8080/signup', :fname => @invitation.recipient_firstname, :lname => @invitation.recipient_lastname, :uname => 'demo.user', :org => @invitation.recipient_company, :email => @invitation.recipient_email, :title => @invitation.recipient_title
      if response.code == 200
        json_body = JSON.parse response
        @invitation.recipient_username = json_body['username']
        @invitation.save!
        account_created = true
      end
    rescue => e
      @invitation.errors[:base] << "Sorry! Could not contact the AD Server at this time. Please try again later!"
      logger.error "error contacting AD server"
      puts e
    end

    respond_to do |format|
      if account_created
        WelcomeUserMailer.welcome_email(@invitation,json_body['password']).deliver
        SignupWorker.perform_async('bob', 5)
        format.html { redirect_to @invitation, notice: 'Invitation was successfully created.' }
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
      response = RestClient.post 'http://75.126.198.236:8080/unregister', :username => @invitation.recipient_username
      if response.code == 200
        @invitation.destroy
        account_removed = true
      end
    rescue => e
      format.html { render :new }
    end

    #Update the invitation limit
    @user = @invitation.sender
    @user.invitation_limit += 1
    @user.save!

    respond_to do |format|
      format.html { redirect_to invitations_url, notice: 'Invitation was successfully destroyed.' }
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
