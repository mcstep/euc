class AccountActiveDirectoryHorizonSyncWorker
  include Sidekiq::Worker

  def perform
    if ENV["TRYGRID_AD_ENABLED"].to_b
      puts "Calling sync service for home region.."
      region = 'dldc' # Yes. because that is the only workspace now
      begin
        home_sync_url = "#{ENV['API_HOST']}/sync/#{region}"
        response = RestClient.post(url=home_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
        puts response.body
      rescue => e
        puts e
      end
      puts "Sync success"
    end
    AccountActiveDirectoryAmericaReplicateWorker.perform_async
  end
end
