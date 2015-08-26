class MoveAirwatchSettingsFromProfilesToInstances2 < ActiveRecord::Migration
  def change
    Profile.all.each do |profile|
      profile.integrations.joins(:airwatch_instance).each do |integration|
        next unless integration.airwatch_instance

        integration.airwatch_instance.use_admin = profile.airwatch_admins_supported
        integration.airwatch_instance.use_groups = profile.airwatch_create_groups
        integration.airwatch_instance.save!
      end
    end

    remove_column :profiles, :airwatch_admins_supported
    remove_column :profiles, :airwatch_create_groups
    remove_column :profiles, :airwatch_notify_by_email
  end
end
