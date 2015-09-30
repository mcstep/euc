namespace :maintain do
  task :remove_user_from_legacy_airwatch => :environment do
    instance = AirwatchInstance.where(host: 'testdrive.awmdm.com').first

    unless instance.present?
      puts "The AW instance with host `testdrive.awmdm.com` isn't defined."
      exit
    end

    Upgrade::Invitation.with_deleted.where.not(airwatch_user_id: nil).pluck(:airwatch_user_id).each do |id|
      begin
        instance.deactivate(id)
        instance.delete_user(id)
        puts "ID #{id} deleted"
      rescue Exception => e
        puts "ID #{id}: #{e}"
      end
    end
  end

  task :set_proper_status_to_deprovisioned_google_apps_users => :environment do
    UserIntegration.where(google_apps_status: UserIntegration.google_apps_statuses[:provisioned]).each do |ui|
      unless ui.integration.google_apps_instance.registered?(ui)
        ui.google_apps_status = UserIntegration.google_apps_statuses[:deprovisioned]
        ui.save!

        ui.user.authentication_integration.directory.remove_group(
          ui.user.authentication_integration.username,
          'GoogleAppsUsers',
          ui.user.authentication_integration.integration.domain
        )
      end
    end
  end

  task :add_horizon_users_to_group => :environment do
    User.joins(:integrations).where.not(integrations: {horizon_view_instance_id: nil}).each do |user|
      user.authentication_integration.directory.add_group(
        user.authentication_integration.username,
        'HorizonViewUsers',
        user.authentication_integration.integration.domain
      )
    end

    Profile.where(name: 'Default').first.integrations.each do |i|
      i.directory.replicate
      i.directory.sync('vidm')
    end
  end

  task :add_users_to_vidm_group => :environment do
    User.all.each do |user|
      user.authentication_integration.directory.add_group(
        user.authentication_integration.username,
        'VIDMUsers',
        user.authentication_integration.integration.domain
      )
    end
  end

  task :add_airwatch_users_to_google_group => :environment do
    UserIntegration.where.not(airwatch_user_id: nil).includes(:user).map(&:user).uniq.each do |user|
      if user.profile.name == 'Default'
        user.authentication_integration.directory.add_group(
          user.authentication_integration.username,
          'GoogleAppsUsers',
          user.authentication_integration.integration.domain
        )
      end
    end
  end

  task :reset_airwatch_provisioning => :environment do
    UserIntegration.where(airwatch_status: UserIntegration.airwatch_statuses[:provisioned]).update_all(airwatch_status: UserIntegration.airwatch_statuses[:deprovisioned])
  end
end