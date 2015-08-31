namespace :maintain do
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
    UserIntegration.where.not(airwatch_user_id: nil).each do |ui|
      user = ui.user
      user.authentication_integration.directory.add_group(
        user.authentication_integration.username,
        'GoogleAppsUsers',
        user.authentication_integration.integration.domain
      )
    end
  end

  task :reset_airwatch_provisioning => :environment do
    User.where(airwatch_status_id: UserIntegration.airwatch_statuses[:provisioned]).update_all(airwatch_status_id: UserIntegration.airwatch_statuses[:deprovisioned])
  end
end