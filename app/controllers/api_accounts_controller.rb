class ApiAccountsController < BaseApiController
  include ActiveDirectoryHelper
  before_filter :find_account, only: [:show, :update, :delete, :reset_password, :change_password]

  before_filter only: :create do
    unless @json.has_key?('account') && @json['account']['first_name'] && @json['account']['last_name'] && @json['account']['email'] && @json['account']['country_code'] && @json['account']['company'] #&& @json['account'].responds_to?(:[]) 
      render nothing: true, status: :bad_request
    end
  end

  before_filter only: :change_password do
    unless @json.has_key?('account') && @json['account']['current_password'] && @json['account']['new_password'] 
      render nothing: true, status: :bad_request
    end
  end

  before_filter only: :update do
    unless @json.has_key?('account') && @json['account']['expiration_date']
      render nothing: true, status: :bad_request
    end
  end

  before_filter only: :create do
    @account = Account.find_by_email(@json['account']['email'])
  end

  def index
    all_accounts_json = []

    since = params.has_key?(:since) ? params[:since] : nil
    limit_param = params.has_key?(:limit) ? params[:limit] : nil
    offset_param = params.has_key?(:offset) ? params[:offset] : nil

    if !limit_param.nil? && offset_param.nil?
      offset_param = 0
    end

    all_accounts = nil
    if since.nil?
      all_accounts = Account.all.limit(limit_param).offset(offset_param)
    else
      since_time = DateTime.parse(since)
      all_accounts = Account.where("created_at > '#{since_time}'").limit(limit_param).offset(offset_param)
    end

    all_accounts.each do |account|
      account_json = build_account_json (account)
      all_accounts_json << account_json
    end

    render json: all_accounts_json
  end

  def show
    #render :json => @account.to_json(:include => [:id])
    response_json = build_account_json (@account)
    render json: response_json
  end

  def delete
    account_removed, response = delete_user(@account.username)

    if account_removed && response &&  @account.destroy
      render nothing: true, status: 200
    else
      render nothing: true, status: :bad_request
    end
  end

  def create
    #existing_user = does_user_exist(@json['account']['username'].downcase)
    #if existing_user
    #  @json['account']['username'] = @json['account']['first_name'].downcase + "." + @json['account']['last_name'].downcase + "." + rand(101...999).to_s
    #  puts "New Username #{@json['account']['username']}"
    #end

    user_name = @json['account']['email'].downcase.split("@").first
    existing_user = does_user_exist(@json['account']['email'].downcase.split("@").first)
    while existing_user != nil do
      user_name = @json['account']['email'].downcase.split("@").first + "." + rand(101...999).to_s
      puts "User exists, trying with Username #{user_name}"
      existing_user = does_user_exist(user_name)
    end

    if @account.present? #|| (existing_user != nil)
      render nothing: true, status: :conflict
    else
      @account = Account.new
      @account.assign_attributes(@json['account'])

      @account.uuid = SecureRandom.uuid
      @account.account_source = 'trygrid' #0
      @account.expiration_date = Time.now # Yes, create an expired account which will be extended later
      #@account.expiration_date = Time.now + ENV["TRYGRID_ACCOUNT_VALIDITY_HOURS"].to_i.hour #8.hour
      @account.username =  user_name
      @account.job_title = 'Employee' # Hardcoded for now
      @account.home_region = 'AMER'
      
      account_created, json_response = create_user(@account.first_name, 
                                    @account.last_name, 
                                    @account.email, 
                                    @account.company, 
                                    @account.job_title, 
                                    @account.username, 
                                    @account.expiration_date, 
                                    @account.home_region)

      # Remove user from VMWDemousers
      user_removed = remove_user_from_group(user_name,'vmwdemousers')
      # Add user to TryGridUsers
      user_added = add_user_to_group(user_name,'trygridusers')

      if account_created && json_response && json_response['username'] && json_response['password'] &&  @account.save
        response_json = build_account_json (@account)
        response_json['username']   = json_response['username']
        response_json['password']   = json_response['password']

        render json: response_json # TODO: Render username and password as well

        AccountActiveDirectoryFolderCreateWorker.perform_async(@account.id)
      else
        render nothing: true, status: :bad_request
      end
    end
  end

  def update
    @account.assign_attributes(@json['account']) #TODO: Dangerous, maybe not do this and manually set the new exp date?

    account_extended = extend_user_account(@account.username, @json['account']['expiration_date'])

    if account_extended && @account.save
        response_json = build_account_json (@account)
        render json: response_json
        AccountActiveDirectoryAmericaReplicateWorker.perform_async
    else
        render nothing: true, status: :bad_request
    end
  end

  def reset_password
    password_reset, response = reset_user_password(@account.username, @account.email)
    if password_reset == true
      response_json = {}
      response_json['new_password'] = response
      render json: response_json, status: 200
      AccountActiveDirectoryAmericaReplicateWorker.perform_async
    else
      render nothing: true, status: :bad_request
    end
  end

  def change_password
    authentication_success = authenticate(@account.username, @json['account']['current_password'])
    if authentication_success == false
      render nothing: true, status: :bad_request
      return
    end

    password_change, response = change_user_password(@account.username, @json['account']['new_password'])
    if password_change == true
      render nothing: true, status: 200
      AccountActiveDirectoryAmericaReplicateWorker.perform_async
    else
      render nothing: true, status: :bad_request
    end
  end

 private
   def find_account
     @account = Account.find_by_uuid(params[:uuid])
     render nothing: true, status: :not_found unless @account.present? #&& @account.user == @user
   end

   def build_account_json (account)
      response_json = {}
      response_json['uuid'] = account.uuid
      response_json['username']   = account.username
      response_json['first_name'] = account.first_name
      response_json['last_name']  = account.last_name
      response_json['email']      = account.email
      response_json['company']    = account.company
      #response_json['job_title']  = account.job_title
      response_json['country_code'] = account.country_code

      sanitized_desktopname = URI.encode(ENV["TRYGRID_VIEW_DESKTOPNAME"])
      response_json['connection_url'] = URI.encode("vmware-view://#{account.username}@#{ENV["TRYGRID_VIEW_SERVERNAME"]}/#{sanitized_desktopname}?action=start-session&domainName=vmwdemo")

      response_json['expiration_date'] = account.expiration_date
      response_json['create_date'] = account.created_at
      response_json['update_date'] = account.updated_at


      return response_json
   end
 end