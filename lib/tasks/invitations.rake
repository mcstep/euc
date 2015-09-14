namespace :invitations do
  task :update_crm => :environment do
    InvitationUpdateCrmWorker.new.perform
  end
end