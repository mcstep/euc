User.where(email: 'root@vmwdemo.com').first_or_create do |u|

  u.company_name          = 'Company'
  u.profile               = Profile.where(name: 'Default').first
  u.role                  = 'root'
  u.first_name            = 'Default'
  u.last_name             = 'User'
  u.home_region           = 'apac'
  u.integrations_username = 'first.user'
end

User.where(email: 'user@apple.com').first_or_create do |u|

  u.company_name          = 'Apple'
  u.profile               = Profile.where(name: 'Apple').first
  u.role                  = 'user'
  u.first_name            = 'Apple'
  u.last_name             = 'User'
  u.home_region           = 'apac'
  u.integrations_username = 'first.user'
end