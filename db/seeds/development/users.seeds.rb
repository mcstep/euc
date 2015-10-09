after 'development:profile_default', 'development:profile_apple' do
  User.where(email: 'administrator+first.user@vmwdev.com').first_or_create! do |u|

    u.company_name          = 'Company'
    u.profile               = Profile.where(name: 'Default (Staging)').first
    u.role                  = 'root'
    u.first_name            = 'Default'
    u.last_name             = 'User'
    u.home_region           = 'apac'
    u.job_title             = 'CEO'
    u.integrations_username = 'first.user'
    u.skip_provisioning     = true
    u.can_edit_services     = true
    u.can_see_reports       = true
    u.can_see_opportunities = true
  end

  User.where(email: 'user@apple.com').first_or_create! do |u|

    u.company_name          = 'Apple'
    u.profile               = Profile.where(name: 'Apple (Staging)').first
    u.role                  = 'basic'
    u.first_name            = 'Apple'
    u.last_name             = 'User'
    u.home_region           = 'apac'
    u.job_title             = 'CEO'
    u.integrations_username = 'first.user'
    u.skip_provisioning     = true
  end
end