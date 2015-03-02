class AccountActiveDirectoryFolderCreateWorker
  include Sidekiq::Worker

  def perform(account_id)
    @account = Account.find_by_id(account_id)
    puts "Will start working on Invitation ID#{account_id} for Recipient #{@account.email}"
    
    if ENV["TRYGRID_AD_ENABLED"].to_b
      region = "dldc"
      puts "Creating user profile directory in home region.."
      begin
        create_dir_url = "#{ENV['API_HOST']}/createdir"
        response = RestClient.post(url=create_dir_url,payload={:username => @account.username, :region => region}, headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
      puts "Created user profile directory successfully in home region"

      puts "Creating user profile directory in remaining regions.."
      rem_regions = ['amer', 'dldc', 'emea', 'apac'] - ["#{region}"]
      rem_regions.each do |sync_reg|
        begin
          create_dir_url = "#{ENV['API_HOST']}/createdir"
          response = RestClient.post(url=create_dir_url,payload={:username => @account.username, :region => sync_reg}, headers= {:token => ENV["API_KEY"]})
          puts response.body
        rescue => e
          puts e
        end
      end
    end
      puts "Created user profile directory successfully in other regions"
      AccountActiveDirectoryHorizonSyncWorker.perform_async
  end
end
