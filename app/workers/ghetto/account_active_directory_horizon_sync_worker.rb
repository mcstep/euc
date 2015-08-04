module Ghetto
  class AccountActiveDirectoryHorizonSyncWorker
    include Sidekiq::Worker

    def perform
      if ENV["TRYGRID_AD_ENABLED"].to_b
        puts "Calling sync service for home region.."
        region = 'dldc' # Yes. because that is the only workspace now
        begin
          home_sync_url = "#{ENV['TRYGRID_API_HOST']}/sync/#{region}"
          response = RestClient.post(url=home_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["TRYGRID_API_KEY"]})
          puts response.body
        rescue => e
          puts e
        end
        puts "Sync success"
      end
      Ghetto::AccountActiveDirectoryAmericaReplicateWorker.perform_async
      Ghetto::AccountActiveDirectoryEuropeReplicateWorker.perform_async
    end
  end
end