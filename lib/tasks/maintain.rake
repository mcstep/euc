namespace :maintain do
  task :strip_companies => :environment do
    Company.all.each do |company|
      company.name.strip!
      company.save!(validate: false)
    end
  end

  task :merge_companies => :environment do
    Company.group(:name).having('count(name) > 1').pluck(:name).each do |duplicate_name|
      company       = Company.where(name: duplicate_name).order(:id).first
      duplicate_ids = Company.where(name: duplicate_name).where.not(id: company.id).pluck(:id)

      company.transaction do
        [Customer, Domain, Partner, User].each do |model|
          model.where(company_id: duplicate_ids).update_all(company_id: company.id)
        end

        Company.where(id: duplicate_ids).delete_all
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