after :instances do
  integration = Integration.where(domain: 'vmwdemo.com').first_or_create do |i|

    i.name                 = 'Integrations'
    i.directory            = Directory.where(host: 'staging.vmwdemo.com').first
    i.airwatch_instance    = AirwatchInstance.where(host: 'testdrive.awmdm.com').first
    i.google_apps_instance = GoogleAppsInstance.where(act_on_behalf: 'admin@vmwdemo.com').first
  end

  Profile.where(name: 'Default').first_or_create do |p|

    p.supports_vidm        = false
    p.profile_integrations = [ProfileIntegration.new(
      allow_sharing: true,
      integration:   integration
    )]
  end
end