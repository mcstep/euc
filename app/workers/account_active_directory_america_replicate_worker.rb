class AccountActiveDirectoryAmericaReplicateWorker
  include Sidekiq::Worker

  def perform
    if !Rails.env.development? && ENV["TRYGRID_AD_ENABLED"].to_b
      puts "Calling ad replicate for america.."
      begin
       ad_sync_url = "#{ENV['API_HOST']}/ad/replicate/amer"
       #response = RestClient.post(url=ad_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
       RestClient::Request.execute(:method => :post, :url => ad_sync_url, :timeout => 200, :open_timeout => 10,  :payload => {:uname => 'demo.user'},  :headers => {:token => ENV["API_KEY"]})
       #puts response.body
      rescue => e
       puts e
      end
      puts "AD replicate for america called successfully"
    end

  end
end
