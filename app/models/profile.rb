# == Schema Information
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profiles_on_deleted_at  (deleted_at)
#

class Profile < ActiveRecord::Base
  acts_as_paranoid

  has_many :profile_integrations

  def self.default
    profile = where(name: 'Default').first

    return profile if profile

    profile     = Profile.create(name: 'Default')
    integration = Integration.create!(
      name: 'Integrations',
      domain: 'vmwdemo.com',
      directory: Directory.create!(
        host: 'staging.vmwdemo.com',
        port: '8080',
        api_key: '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
      ),
      airwatch_instance: AirwatchInstance.create!(
        group_name: 'AirWatchUsers',
        group_region: 'dldc',
        host: 'testdrive.awmdm.com',
        api_key: '1SYEHIBAAAG6A7PQAEQA',
        user: 'api.admin',
        password: 'VMware123!',
        parent_group_id: '570'
      ),
      google_apps_instance: GoogleAppsInstance.create!(
        key: File.open(Rails.root.join 'config','privatekey.p12').read,
        key_password: 'notasecret',
        initial_password: 'Passw0rd1',
        service_account: '1022878145273-bbsae5pdlpj4mh0f49icrvcgtfo78a6u@developer.gserviceaccount.com',
        act_on_behalf: 'admin@vmwdemo.com'
      )
    )

    ProfileIntegration.create!(
      profile_id: profile.id,
      integration_id: integration.id,
      allow_sharing: true
    )

    profile
  end
end
