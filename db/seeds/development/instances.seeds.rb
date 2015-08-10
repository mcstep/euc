Directory.where(host: 'receiver.vmwdev.com').first_or_create! do |d|

  d.use_ssl = true
  d.port    = 443
  d.api_key = '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
end

AirwatchInstance.where(host: 'airwatch.vmwdev.com').first_or_create! do |ai|

  # ai.group_name      = 'AirWatchUsers'
  # ai.group_region    = 'dldc'
  ai.api_key         = 'UIZaNu6vmqxFf3MKAxslgOK9fJOJfyH757xuvbRLvNs='
  ai.user            = 'api.admin'
  ai.password        = 'vmwareHelp!'
  ai.parent_group_id = 570
  ai.security_pin    = 1111
  ai.admin_roles     = [
    { 'Id' => '10107', 'LocationGroupId'=> '1956' },
    { 'Id'=> '10108',  'LocationGroupId'=> '1983' },
    { 'Id'=> '10109',  'LocationGroupId'=> '1977' },
    { 'Id'=> '10107',  'LocationGroupId'=> '1551' },
    { 'Id'=> '87',     'LocationGroupId'=> '1251' }
  ]
end

GoogleAppsInstance.where(act_on_behalf: 'administrator@vmwdev.com').first_or_create! do |gai|

  # gai.group_name       = 'GoogleAppsUsers'
  # gai.group_region     = 'dldc'
  gai.key              = File.open(Rails.root.join 'spec', 'factories', 'data', 'google_apps.p12').read
  gai.key_password     = 'notasecret'
  gai.initial_password = 'Passw0rd1'
  gai.service_account  = '1017868876365-qanhsqob5de941vq704utiu6sjmgibkc@developer.gserviceaccount.com'
end

Office365Instance.where(client_id: 'cd329bba-1082-40a1-93e9-496370a53f18').first_or_create do |oi|

  # oi.group_name    = 'Office365Users'
  # oi.group_region  = 'dldc'
  oi.client_secret = 'sZp1HMkFBfPNjdPj3Qy5N563W4qVkz9eEqn49VErI6k='
  oi.tenant_id     = '01b78576-ce65-44db-841f-e2ea4c7c5db0'
  oi.resource_id   = 'https://graph.windows.net'
end

HorizonInstance.where(api_host: 'receiver.vmwdev.com').first_or_create! do |hi|

  # hi.view_group_name    = 'HorizonViewUsers'
  # hi.group_region       = 'dldc'
end