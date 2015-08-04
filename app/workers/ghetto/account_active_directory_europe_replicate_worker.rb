module Ghetto
  class AccountActiveDirectoryEuropeReplicateWorker
    include Sidekiq::Worker

    def perform
      if !Rails.env.development? && ENV["TRYGRID_AD_ENABLED"].to_b
        puts "Calling ad replicate for emea.."
        begin
         ad_sync_url = "#{ENV['TRYGRID_API_HOST']}/ad/replicate/emea"
         #response = RestClient.post(url=ad_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["TRYGRID_API_KEY"]})
         RestClient::Request.execute(:method => :post, :url => ad_sync_url, :timeout => 200, :open_timeout => 10,  :payload => {:uname => 'demo.user'},  :headers => {:token => ENV["TRYGRID_API_KEY"]})
         #puts response.body
        rescue => e
         puts e
        end
        puts "AD replicate for emea called successfully"
      end

    end
  end
end