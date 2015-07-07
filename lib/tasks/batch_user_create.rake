desc "This class is used to batch create user accounts on VMware Testdrive Portal"

  task :batch_user_create, [:arg0] => :environment do |t, args|
    require "csv"
    require 'net/http'
    require 'rest-client'

    puts "BATCH: Args were: #{args}"
    uri = URI(args[:arg0])
    csv_text = Net::HTTP.get(uri)
    csv = CSV.parse(csv_text, :headers=>true)
    csv.each do |row|
      firstname = row[0].downcase.strip
      lastname = row[1].downcase.strip
      email = row[2].downcase.strip
      job_title = row[3].strip
      company = row[4].strip
      region = row[5].upcase.strip

      @invitation = Invitation.new
      @invitation.recipient_firstname = firstname
      @invitation.recipient_lastname = lastname
      @invitation.recipient_email = email
      @invitation.region = region
      @invitation.recipient_company = company
      @invitation.recipient_title = job_title

      begin
        if @invitation.save!
          puts "BATCH: Invitation successfully created for #{email}. Will call AD provisioning for Invitation ID #{@invitation.id}"
          BatchSignupWorker.new.perform(@invitation.id)
        end
      rescue Exception => e
        puts "BATCH: Error creating Invitation for #{email}. Exception: #{e}"
        next
      end
    end

    puts "BATCH: Done with creation of accounts. Will call Workspace Portal sync.."
    begin
      home_sync_url = "#{ENV['API_HOST']}/sync/dldc"
      response = RestClient.post(url=home_sync_url,
                                 payload={:uname => 'demo.user'}, 
                                 headers= {:token => ENV["API_KEY"]})
      puts response.body
    rescue => e
      puts e
    end
    puts "BATCH: Sync success for Workspace Portal"


    puts "BATCH: Done with Workspace Portal Sync. Will call AD Replicate.."
    AccountActiveDirectoryReplicateWorker.perform_async
  end