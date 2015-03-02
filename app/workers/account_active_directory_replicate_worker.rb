class AccountActiveDirectoryReplicateWorker
  include Sidekiq::Worker

  def perform
    if !Rails.env.development?
      puts "Calling ad replicate.."
      begin
       ad_sync_url = "#{ENV['API_HOST']}/ad/replicate"
       #response = RestClient.post(url=ad_sync_url,payload={:uname => 'demo.user'}, headers= {:token => ENV["API_KEY"]})
       RestClient::Request.execute(:method => :post, :url => ad_sync_url, :timeout => 200, :open_timeout => 10,  :payload => {:uname => 'demo.user'},  :headers => {:token => ENV["API_KEY"]})
       puts response.body
      rescue => e
       puts e
      end
      puts "AD replicate called successfully"
    end

  end
end
