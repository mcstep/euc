namespace :invitations do
  task :force_update_crm => :environment do
    InvitationUpdateCrmWorker.new.perform(force: true)
  end

  task :update_crm => :environment do
    InvitationUpdateCrmWorker.new.perform
  end
end