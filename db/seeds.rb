UserIntegration.delete_all
User.delete_all
RegistrationCode.delete_all
Invitation.delete_all
Integration.delete_all
AirwatchInstance.delete_all
GoogleAppsInstance.delete_all
Company.delete_all
Profile.delete_all

profile = Profile.create!(name: 'Profile')
company = Company.create!(name: 'Company')

integration = Integration.create!(
  name: 'Integrations',
  directory: Directory.create!(
    host: 'staging.vmwdemo.com',
    port: '8080',
    api_key: '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
  ),
  airwatch_instance: AirwatchInstance.create!(
    group_name: 'VMWDEMOUsers',
    host: 'testdrive.awmdm.com',
    api_key: '1SYEHIBAAAG6A7PQAEQA',
    user: 'api.admin',
    password: 'VMware123!',
    parent_group_id: '570'
  ),
  google_apps_instance: GoogleAppsInstance.create!(
    group_name: 'VMWDEMOUsers',
    key: File.open(Rails.root.join 'config','privatekey.p12').read,
    key_password: 'notasecret',
    domain: 'vmwdemo.com',
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

root = User.create!(
  email: 'root@vmwdemo.com',
  company_id: company.id,
  profile_id: profile.id,
  role: 'root',
  first_name: 'First',
  last_name: 'User',
  home_region: 'apac',
  integrations_username: 'first.user'
)

Invitation.create!(
  from_user_id: root.id,
  to_user_attributes: {
    email: 'admin@vmdemo.com',
    company_id: company.id,
    role: 'admin',
    first_name: 'Invited',
    last_name: 'User',
    home_region: 'apac'
  },
)