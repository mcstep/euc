desc 'This task syncronizes the users table with the invitations table in the backing database'

task :synchronize_users_with_invitations => :environment do
  ActiveRecord::Base.transaction do
    User.update_all('invitation_id = (SELECT id FROM invitations WHERE recipient_username = users.username AND deleted_at IS NULL)')

    users = User.where(:invitation_id => nil)

    if users.count > 0
      puts "The following users rows failed:"
      puts "id: username"

      users.each do |user|
        puts "#{user.id}: #{user.username}"
      end

      puts
      raise ActiveRecord::Rollback, "Not all invitation_id fields could be set."
    end
  end
end
