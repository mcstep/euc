after :instances do
  integration = Integration.where(domain: 'vmtestdrive.com').first_or_create do |i|

    i.name                 = 'Airwatch + Office365 for Apple'
    i.directory            = Directory.where(host: 'api.vmwdemo.com').first
    i.airwatch_instance    = AirwatchInstance.where(host: 'apple.awmdm.com').first
    i.office365_instance   = Office365Instance.where(client_id: 'f2c1eb0b-1d1d-45a9-91ed-f0d208cf96f6').first
  end

  profile = Profile.where(name: 'Apple').first_or_create do |p|

    p.group_name                = 'TestdriveAppleUsers'
    p.group_region              = 'dldc'
    p.home_template             = 'apple'
    p.support_email             = 'salessupport@air-watch.com'
    p.airwatch_admins_supported = true
    p.profile_integrations      = [ProfileIntegration.new(
      allow_sharing: true,
      integration:   integration
    )]
  end

  %w(vmwdev.com apple.com).each do |domain|
    Domain.where(name: domain).first_or_create do |d|

      d.company_name = 'Apple.com'
      d.profile      = profile
      d.name         = domain
      d.user_role    = User::ROLES[:basic]
    end
  end
end