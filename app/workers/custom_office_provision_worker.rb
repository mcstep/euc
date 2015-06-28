require 'json'
require 'date'
require 'rqrcode_png'

class CustomOfficeProvisionWorker
  include Sidekiq::Worker

  def perform(invitation_id, password)
    @invitation = Invitation.find(invitation_id)
    domain_suffix = ENV['CUSTOM_DOMAINS_SUFFIX']

    puts "Will start Office 365 provisioning for #{@invitation.recipient_username}:#{@invitation.recipient_email}"

    puts "Calling ad replicate ad2.."
    begin
      ad_sync_url = "#{ENV['API_HOST']}/ad/replicate/ad2"
      RestClient::Request.execute(  :method => :post, 
                                    :url => ad_sync_url, 
                                    :timeout => 200, 
                                    :open_timeout => 10,  
                                    :payload => {:uname => 'demo.user'},  
                                    :headers => {:token => ENV["API_KEY"]})
    rescue => e
      puts e
    end
    puts "AD replicate ad2 called successfully"

    #TODO: Create this endpoint on the receiver
    puts "Calling Office 365 Sync for #{@invitation.recipient_username}"
    begin
      ad_sync_url = "#{ENV['API_HOST']}/office365/sync"
      RestClient::Request.execute(  :method => :post, 
                                    :url => ad_sync_url, 
                                    :timeout => 200, 
                                    :open_timeout => 10,  
                                    :payload => {:username => "#{@invitation.recipient_username}",
                                                 :domain_suffix => domain_suffix},  
                                    :headers => {:token => ENV["API_KEY"]})
    rescue => e
      puts e
    end
    puts "Office 365 Sync called successfully"

    sleep 10;

    if ENV["O365_GRAPH_API_USAGE_LOCATION"].to_b
      puts "Calling Azure Graph API to set usage location for user #{@invitation.recipient_username}@#{domain_suffix}"
      begin
        azure = Azure::Directory::Client.new
        azure.update_user("#{@invitation.recipient_username}@#{domain_suffix}", {'usageLocation' => 'US'} 
                          )
        puts "Successfully called Azure Graph API to update usage location for user #{@invitation.recipient_username}@#{domain_suffix}"
      rescue => e
        puts "Error setting O365 usage location for user #{@invitation.recipient_username}@#{domain_suffix}: {e}"
      end
    else
      puts "Azure GRAPH API disabled. Won't set usage location for user #{@invitation.recipient_username}@#{domain_suffix}"
    end

    if ENV["O365_GRAPH_API_ASSIGN_LICENSE"].to_b
      puts "Calling Azure Graph API to set license for user #{@invitation.recipient_username}@#{domain_suffix}"
      begin
        azure = Azure::Directory::Client.new
        azure.assign_license("#{@invitation.recipient_username}@#{domain_suffix}", "STANDARDPACK")

        puts "Successfully called Azure Graph API to set license for user #{@invitation.recipient_username}@#{domain_suffix}"
      rescue => e
        puts "Error setting O365 license for user #{@invitation.recipient_username}@#{domain_suffix}: {e}"
      end
    else
      puts "Azure GRAPH API disabled. Won't set license for user #{@invitation.recipient_username}@#{domain_suffix}"
    end

    if ENV["O365_GRAPH_API_PASSWORD_RESET"].to_b
      puts "Calling Azure Graph API to set password for user #{@invitation.recipient_username}@#{domain_suffix}"
      begin
        azure = Azure::Directory::Client.new
        azure.update_user("#{@invitation.recipient_username}@#{domain_suffix}", 
                           {'passwordProfile' => 
                                                {'password' => "#{password}", 
                                                'forceChangePasswordNextLogin' => 'false'} 
                                                }
                          )
        puts "Successfully called Azure Graph API to update password for user #{@invitation.recipient_username}@#{domain_suffix}"
      rescue => e
        puts "Error resetting O365 password for user #{@invitation.recipient_username}@#{domain_suffix}: {e}"
      end
    else
      puts "Azure AD password reset disabled. Won't reset password for user #{@invitation.recipient_username}@#{domain_suffix}"
    end

    CustomAirwatchProvisionWorker.perform_async(invitation_id)
 end
end
