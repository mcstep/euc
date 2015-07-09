UserIntegration.delete_all
User.delete_all
RegistrationCode.delete_all
Invitation.delete_all
Integration.delete_all
AirwatchInstance.delete_all
GoogleAppsInstance.delete_all
Company.delete_all
Profile.delete_all

company = Company.create!(name: 'Company')
profile = Profile.default
root    = User.create!(
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