class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  before_action :require_admin , except: [:unimpersonate, :check_invitation, :create, :destroy, :extend]

  def check_invitation
    @invitation = Invitation.find_by_recipient_email(params[:invitation][:recipient_email].downcase)
    respond_to do |format|
      format.json { render :json => !@invitation }
    end
  end

  # GET /invitations
  # GET /invitations.json
  def index
    search = params[:search]

    query = Invitation
      .select("invitations.*, users.role")
      .joins('LEFT OUTER JOIN users ON users.invitation_id = invitations.id')
      .order(:recipient_firstname)
      .page params[:page]

    if !search.blank?
      if search.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
        query = query.where('recipient_email LIKE ?', "%#{search}%")
      elsif search.match(/\w+ \w+/i)
        firstname,lastname = search.split(" ")
        query = query.where('recipient_firstname LIKE ? AND recipient_lastname LIKE ?', "%#{firstname}%", "%#{lastname}%")
      else
        needle = "%#{search}%"
        query = query.where('recipient_firstname LIKE ? OR recipient_lastname LIKE ? OR recipient_username LIKE ? OR recipient_email LIKE ?', needle, needle, needle, needle)
      end
    end

    @invitations = query
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
    puts invitation_params
    @invitation = Invitation.new(invitation_params)

    # Check for sender
#    if @invitation.sender.blank?
#      respond_to do |format|
#	flash.now.alert = "Invalid request"
#        format.html { render :new }
#      end
#    end

    # Check for whitespaces and remove them
    if @invitation.recipient_username.blank?
      @invitation.recipient_username = nil
    end

    # Make google apps same as airwatch, for now
    @invitation.google_apps_trial = @invitation.airwatch_trial

    @invitation.sender = current_user
    if !params[:invitation][:expires_at].blank?
      @invitation.expires_at = Date.parse(params[:invitation][:expires_at])
    else
      @invitation.expires_at = (Time.now + 1.month)
    end
    puts "Region: #{@invitation.region}"
    respond_to do |format|
      if @invitation.save
        user_domain = params[:invitation][:recipient_email].split("@").last.downcase
        custom_domains = [] 
        if ENV['CUSTOM_DOMAINS']
          custom_domains = ENV['CUSTOM_DOMAINS'].split(",")
        end

        if custom_domains.include? user_domain
          CustomProvisionWorker.perform_async(@invitation.id)
        else
          SignupWorker.perform_async(@invitation.id)
        end
        format.html { redirect_to dashboard_path, notice: 'Invitation was successfully created.' }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { redirect_to dashboard_path, alert: 'Invitation cannot be created at this time. Please try again later' }
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
      response = RestClient.post( url="#{ENV['API_HOST']}/unregister",
                                  payload={:username => @invitation.recipient_username,
                                           :domain_suffix => get_domain_suffix(@invitation.recipient_email)}, 
                                  headers= {:token => ENV["API_KEY"]})
      puts "Got response #{response} for account deletion"

      if response.code == 200
        @invitation.destroy
        @user_rec_for_invite = User.find_by_email(@invitation.recipient_email)
        @user_rec_for_invite.destroy unless @user_rec_for_invite.nil?
        account_removed = true
        AccountExpireEmailWorker.perform_async(@invitation.id)
        # Remove AirWatch account if the user is already enrolled
        if !@invitation.airwatch_user_id.nil?
          user_domain = @invitation.recipient_email.split("@").last.downcase
          custom_domains = [] 
          if ENV['CUSTOM_DOMAINS']
            custom_domains = ENV['CUSTOM_DOMAINS'].split(",")
          end
          domain_suffix = ENV['CUSTOM_DOMAINS_SUFFIX']

          if custom_domains.include? user_domain
            CustomUnprovisionWorker.perform_async(@invitation.id)
          else
            AirwatchUnprovisionWorker.perform_async(@invitation.id)
          end
        end
      end
    rescue RestClient::Exception
      redirect_to dashboard_path, alert: "Could not delete the user's account"
      return
    rescue Exception => e
      puts e
      redirect_to dashboard_path, alert: "Unable to delete the user's account at this time. Please try again later"
      return
    end

    #Update the invitation limit
    @user = @invitation.sender

    if !@user.nil?
     @user.invitation_limit += 1
     #new invitation limit model
     @user.invitations_used -= 1
     @user.save!
    end

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: 'Invitation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # WARNING: All updates here should be reflected in the extend_super_user task.
  def extend
    #Extend the AD account
    account_extended = false

    @invitation = Invitation.find_by_id(params[:invitationId])

    original_expires_at = @invitation.expires_at
    @invitation.expires_at = Date.parse(params[:expiresAt])

    begin
      response = RestClient.post( url="#{ENV['API_HOST']}/extendAccount",
                                  payload={:username => @invitation.recipient_username,  
                                           :expires_at => ((@invitation.expires_at.to_i)*1000),
                                           :domain_suffix => get_domain_suffix(@invitation.recipient_email)}, 
                                  headers= {:token => ENV["API_KEY"]})
      puts "Got response #{response} for account extension"

      if response.code == 200
        @invitation.save
      end
    rescue RestClient::Exception
      redirect_to request.referer, alert: "Could not extend the user's account"
      return
    rescue Exception => e
      puts e
      redirect_to request.referer, alert: "Unable to extend the user's account at this time. Please try again later"
      return
    end

    #Add extension record
    @extension = Extension.new
    @extension.extended_by = current_user.id #TODO - Fix @invitation.sender.id
    @extension.recipient = @invitation.id
    @extension.original_expires_at = original_expires_at
    @extension.revised_expires_at = @invitation.expires_at
    @extension.reason = params[:reason]
    @extension.save

    AccountExtensionEmailWorker.perform_async(@invitation.id, @extension.id)

    respond_to do |format|
      format.html { redirect_to request.referer, notice: 'Invitation was successfully extended.' }
      format.json { head :no_content }
    end
  end

  def impersonate
    begin
      #backup the current user so we can go back
      session[:impersonator_id] = current_user.id

      @invitation = Invitation.find_by_id(params[:format])
      @usr = User.find_by_invitation_id(@invitation.id)
      @current_user = @usr
      session[:user_id] = @current_user.id
    rescue Exception => e
      puts e
      redirect_to request.referer, alert: "Unable to impersonate this user at this time. Please try again later"
      return
    end

    redirect_to dashboard_path, notice: 'User was successfully impersonated.'
  end

  def unimpersonate
    begin
      @usr = User.find_by_id(session[:impersonator_id])
      @current_user = @usr
      session[:user_id] = @current_user.id
      session[:impersonator_id] = nil
    rescue Exception => e
      puts e
      redirect_to request.referer, alert: "Unable to return to normal at this time. Please logout and log back in as admin"
      return
    end

    redirect_to dashboard_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitation_params
      params.require(:invitation).permit(:recipient_firstname, :recipient_lastname, :recipient_email, :recipient_title, :recipient_company, :region, :recipient_username, :expires_at, :potential_seats, :airwatch_trial)
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
