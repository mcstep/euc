class AddGoogleAppsTrialToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :google_apps_trial, :boolean
  end
end
