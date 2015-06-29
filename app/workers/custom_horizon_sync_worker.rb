require 'json'
require 'date'
require 'rqrcode_png'

class CustomHorizonSyncWorker
  include Sidekiq::Worker

  def perform(invitation_id, password)
    @invitation = Invitation.find(invitation_id)
    domain_suffix = ENV['CUSTOM_DOMAINS_SUFFIX']

    puts "Calling ad replicate amer.."
    begin
      ad_sync_url = "#{ENV['API_HOST']}/ad/replicate/amer"
      RestClient::Request.execute(  :method => :post, 
                                    :url => ad_sync_url, 
                                    :timeout => 200, 
                                    :open_timeout => 10,  
                                    :payload => {:uname => 'demo.user'},  
                                    :headers => {:token => ENV["API_KEY"]})
    rescue => e
      puts e
    end
    puts "AD replicate amer called successfully"

    puts "Calling receiver to perform Horizon Sync..."
    begin
      home_sync_url = "#{ENV['API_HOST']}/sync/vidm"
      response = RestClient.post(url=home_sync_url,
                                 payload={:uname => 'demo.user'}, 
                                 headers= {:token => ENV["API_KEY"]})
      puts response.body
      puts "VIDM sync success"
    rescue => e
      puts e
    end

    puts "Sending welcome email for user #{@invitation.recipient_username} to #{@invitation.recipient_email}...."
    WelcomeUserMailer.custom_welcome_email_invited(@invitation,password,domain_suffix).deliver
    puts "Email sent successfully for user #{@invitation.recipient_username} to #{@invitation.recipient_email}"

    AccountActiveDirectoryReplicateWorker.perform_async
  end
end
