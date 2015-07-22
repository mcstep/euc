Directory.where(host: 'staging.vmwdemo.com').first_or_create do |d|

  d.port    = 8080
  d.api_key = '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
end

AirwatchInstance.where(host: 'testdrive.awmdm.com').first_or_create do |ai|

  ai.group_name      = 'AirWatchUsers'
  ai.group_region    = 'dldc'
  ai.api_key         = '1SYEHIBAAAG6A7PQAEQA'
  ai.user            = 'api.admin'
  ai.password        = 'VMware123!'
  ai.parent_group_id = 570
end

AirwatchInstance.where(host: 'apple.awmdm.com').first_or_create do |ai|

  ai.group_name      = 'AirWatchUsers'
  ai.group_region    = 'dldc'
  ai.api_key         = '1LGKA4AAAAG5A5DACEAA'
  ai.user            = 'api.admin'
  ai.password        = '$[5Jd#V7F.'
  ai.parent_group_id = 1250
end

GoogleAppsInstance.where(act_on_behalf: 'admin@vmwdemo.com').first_or_create do |gai|

  gai.key              = File.open(Rails.root.join 'db', 'google_apps.p12').read
  gai.key_password     = 'notasecret'
  gai.initial_password = 'Passw0rd1'
  gai.service_account  = '1022878145273-bbsae5pdlpj4mh0f49icrvcgtfo78a6u@developer.gserviceaccount.com'
end

Office365Instance.where(client_id: 'f2c1eb0b-1d1d-45a9-91ed-f0d208cf96f6').first_or_create do |oi|

  oi.client_secret = 'fHmPz8aJMvsyrTqgoO6AA7TbxSvqC3IvS2qsD9ENXtU='
  oi.tenant_id     = '956587a9-662c-4bf7-bf34-605ab419a893'
  oi.resource_id   = 'https://graph.windows.net'
end