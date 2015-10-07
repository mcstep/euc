Directory.where(host: 'api.vmwdemo.com').first_or_create do |d|

  d.use_ssl   = true
  d.port      = 8443
  d.api_key   = '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
  d.stats_url = 'http://receivertest.vmwdemo.com/%{service}/%{username}/%{kind}?token=token&days=%{days}'
end

AirwatchInstance.where(host: 'testdrive.awmdm.com').first_or_create do |ai|

  ai.group_name         = 'AirWatchUsers'
  ai.group_region       = 'dldc'
  ai.api_key            = '1SYEHIBAAAG6A7PQAEQA'
  ai.user               = 'api.admin'
  ai.password           = 'VMware123!'
  ai.parent_group_id    = 570
  ai.security_pin       = 1111
  ai.templates_api_url  = 'https://awconnector.vmwdev.com/tenants/'
  ai.templates_token    = 'token'
end

AirwatchInstance.where(host: 'apple.awmdm.com').first_or_create do |ai|

  ai.group_name         = 'AirWatchUsers'
  ai.group_region       = 'vidm'
  ai.api_key            = '1LGKA4AAAAG5A5DACEAA'
  ai.user               = 'api.admin'
  ai.password           = '$[5Jd#V7F.'
  ai.parent_group_id    = 1250
  ai.security_pin       = 1111
  ai.use_admin          = true
  ai.use_groups         = false
  ai.templates_api_url  = 'https://awconnector.vmwdev.com/tenants/'
  ai.templates_token    = 'token'
  ai.admin_roles        = [
    { 'Id' => '10107', 'LocationGroupId'=> '1956' },
    { 'Id'=> '10108',  'LocationGroupId'=> '1983' },
    { 'Id'=> '10109',  'LocationGroupId'=> '1977' },
    { 'Id'=> '10107',  'LocationGroupId'=> '1551' },
    { 'Id'=> '87',     'LocationGroupId'=> '1251' }
  ]
end

GoogleAppsInstance.where(act_on_behalf: 'admin@vmwdemo.com').first_or_create do |gai|

  gai.group_name       = 'GoogleAppsUsers'
  gai.group_region     = 'dldc'
  gai.key              = File.open(Rails.root.join 'db', 'google_apps.p12').read
  gai.key_password     = 'notasecret'
  gai.initial_password = 'Passw0rd1'
  gai.service_account  = '1022878145273-bbsae5pdlpj4mh0f49icrvcgtfo78a6u@developer.gserviceaccount.com'
end

Office365Instance.where(client_id: 'f2c1eb0b-1d1d-45a9-91ed-f0d208cf96f6').first_or_create do |oi|

  oi.group_name    = 'O365Users'
  oi.group_region  = 'vidm'
  oi.client_secret = 'fHmPz8aJMvsyrTqgoO6AA7TbxSvqC3IvS2qsD9ENXtU='
  oi.tenant_id     = '956587a9-662c-4bf7-bf34-605ab419a893'
  oi.resource_id   = 'https://graph.windows.net'
  oi.license_name  = 'STANDARDPACK'
end

HorizonInstance.where(api_host: 'api.vmwdemo.com').first_or_create do |hi|

  hi.view_group_name    = 'HorizonViewUsers'
  hi.group_region       = 'dldc'
end