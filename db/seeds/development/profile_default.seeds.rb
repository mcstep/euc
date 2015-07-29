after 'development:instances' do
  integration = Integration.where(domain: 'vmwdev.net').first_or_create do |i|

    i.name                  = 'Integrations'
    i.directory             = Directory.where(host: 'receiver.vmwdev.com').first
    i.airwatch_instance     = AirwatchInstance.where(host: 'airwatch.vmwdev.com').first
    i.google_apps_instance  = GoogleAppsInstance.where(act_on_behalf: 'administrator@vmwdev.com').first
    i.horizon_view_instance = HorizonInstance.where(api_host: 'receiver.vmwdev.com').first
  end

  Profile.where(name: 'Default (Staging)').first_or_create do |p|

    p.supports_vidm        = false
    p.profile_integrations = [ProfileIntegration.new(
      allow_sharing: true,
      integration:   integration
    )]
  end
end