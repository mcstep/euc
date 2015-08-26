after 'development:instances' do
  integration = Integration.where(domain: 'vmwdev.net').first_or_create! do |i|

    i.name                 = 'Airwatch + Office365 for Apple (Staging)'
    i.directory            = Directory.where(host: 'receiver.vmwdev.com').first
    i.airwatch_instance    = AirwatchInstance.where(host: 'airwatch.vmwdev.com').first
    i.office365_instance   = Office365Instance.where(client_id: 'cd329bba-1082-40a1-93e9-496370a53f18').first
  end

  profile = Profile.where(name: 'Apple (Staging)').first_or_create! do |p|

    p.implied_airwatch_eula     = true
    p.group_name                = 'TestdriveAppleUsers'
    p.group_region              = 'dldc'
    p.home_template             = 'apple'
    p.support_email             = 'salessupport@air-watch.com'
    p.profile_integrations_attributes = [{
      allow_sharing: true,
      integration: integration
    }]
  end
end