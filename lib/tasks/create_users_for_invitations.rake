desc 'This task creates missing user records for invitations. It is needed due to a bug in the new schema migration script'

task :create_missing_users_for_invitations => :environment do
  Invitation.all.each do |invitation|
    @user = User.find_by_email(invitation.recipient_email)
    if @user.nil? && !invitation.recipient_username.blank?
      puts "User record missing for Invitation #{invitation.recipient_email}-#{invitation.recipient_username}, creating..."

      begin
        usr = User.new
        usr.username = invitation.recipient_username
        usr.email = invitation.recipient_email
        usr.display_name = invitation.recipient_firstname + " " + invitation.recipient_lastname
        usr.title = invitation.recipient_title
        usr.company = invitation.recipient_company
        usr.invitation_limit = 5
        usr.invitation_id = invitation.id

        custom_domains = [] 
        if ENV['CUSTOM_DOMAINS']
          custom_domains = ENV['CUSTOM_DOMAINS'].split(",")
        end
        user_domain = usr.email.split("@").last.downcase

        if !invitation.reg_code_id.nil?
          reg_code = RegCode.find_by_id(invitation.reg_code_id)
          if !reg_code.nil?
            usr.role =  reg_code.account_type
          else 
            usr.role = 'user'
          end
        elsif custom_domains.include? user_domain
          usr.role = 'user' #All custom domains get regular user role
        else
          @domain = Domain.find_by_name(usr.email.split("@").last)
          # If the user is in one of the whitelisted domains -> assign a vip role
          if !@domain.nil? && @domain.status == 'active'
            usr.role = 'vip'
          else
            usr.role = 'user'
          end
        end
        usr.save!
      rescue => e
        puts "Exception occured while creating User crecord for Invitation #{invitation.recipient_email}. Exception: #{e}. Moving on..."
      end
      puts "Done creating User record for Invitation #{invitation.recipient_email}"
    else
      puts "Found User record for Invitation #{invitation.recipient_email}, moving on"
    end
  end
end