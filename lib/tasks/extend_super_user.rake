desc 'This task automatically extends any super user account expiring in the next N days to a year from their current expiration date'

task :extend_super_user => :environment do
  extend_within = ENV.fetch("SUPER_USER_EXT_DAYS", -1).to_i

  # default value = 15
  if extend_within < 0
    extend_within = 15
  end

  invitations = Invitation
    .joins('INNER JOIN users ON users.invitation_id = invitations.id')
    .where("users.role = ? AND invitations.expires_at <= ?", User.roles["vip"], Date.today + extend_within.days)

  # WARNING:
  #   This code is copied over from InvitationsController::extend.
  #   All updates there should be reflected here.
  # TODO:
  invitations.each do |invitation|
    original_expires_at = invitation.expires_at
    invitation.expires_at = original_expires_at + 1.year

    begin
      response = RestClient.post(url="#{ENV['API_HOST']}/extendAccount",payload={:username => invitation.recipient_username, :expires_at => ((invitation.expires_at.to_i)*1000)}, headers={:token => ENV["API_KEY"]})
      puts "Got response #{response} for account extension"

      if response.code == 200
        invitation.save
      end
    rescue Exception => e
      puts e
      next
    end

    #Add extension record
    @extension = Extension.new
    @extension.extended_by = 0
    @extension.recipient = invitation.id
    @extension.original_expires_at = original_expires_at
    @extension.revised_expires_at = invitation.expires_at
    @extension.reason = "Auto Extension"
    @extension.save

    AccountExtensionEmailWorker.perform_async(invitation.id, @extension.id)
  end
end