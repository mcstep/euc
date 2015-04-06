desc "This task adds a default user with admin rights. This is ONLY to be used in a development environment"

task :add_first_dev_user => :environment do
  if Invitation.find_by_recipient_username('first.user').nil?
    inv = Invitation.new
    inv.recipient_firstname = 'First'
    inv.recipient_lastname = 'User'
    inv.recipient_email = 'admin+firstuser@vmwdemo.com'
    inv.region = 'AMER'
    inv.recipient_username = 'first.user'
    inv.potential_seats = 0
    inv.recipient_title = 'Employee'
    inv.recipient_company = 'VMware'
    inv.airwatch_trial = true
    inv.google_apps_trial = true

    inv.save
  end

  usr = User.find_by_username('first.user')
  if usr.nil?
    usr = User.new
    usr.username = 'first.user'
    usr.role = 'admin'
    usr.email = 'admin+firstuser@vmwdemo.com'
    usr.display_name = 'First User'
    usr.company = 'VMware'
    usr.invitation_limit = 5
    usr.total_invitations = 5
    usr.invitations_used = 0 

    usr.save
  else
    usr.role = 'admin'
    usr.save
  end

  puts "Successfully added first dev user for EUC Global Demo Portal"
end
