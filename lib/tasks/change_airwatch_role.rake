desc "This task will change existing AW user roles from Full Access to VMWDemo"

task :change_airwatch_user_role => :environment do
  puts "Change existing AW user roles from Full Access to VMWDemo"
  invitations = Invitation.all.where.not(airwatch_user_id: nil)
  puts "Found #{invitations.count} invitations in the system with airwatch user ids"
  invitations.each do |inv|
    puts "Working on invite - #{inv.recipient_username}"
    aw_user_id = inv.airwatch_user_id
    begin
      payload = {'Status' => "true",'SecurityType' => "Directory", 'Role' => "VMWDemo"}  
      response = RestClient::Request.execute(:method => :post, :url => "https://testdrive.awmdm.com/API/v1/system/users/#{aw_user_id}/update", :user => "#{ENV['API_USER']}", :password => "#{ENV['API_PASSWORD']}", :headers => {:content_type => :json, :accept => :json,  :host => "testdrive.awmdm.com", :authorization => "Basic bW9oYW46bW9oYW4=", 'aw-tenant-code' => "#{ENV['AIRWATCH_TOKEN']}"}, :payload => payload.to_json)
      if response.code == 200
	      puts "Got Successful AirWatch Response for role change request for User #{inv.recipient_username} with AW ID #{aw_user_id}"
      end
    rescue => e
      puts "Got Exception: #{e} for role change request for User #{inv.recipient_username} with AW ID #{aw_user_id}"
    end
  end
end