class AddAirwatchTrialToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :airwatch_trial, :boolean
  end
end
