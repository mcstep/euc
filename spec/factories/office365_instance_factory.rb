FactoryGirl.define do
  factory :office365_instance do
    group_name      'Office365Users'
    group_region    'dldc'
    client_id       { FFaker::Guid.guid }
    client_secret   { FFaker::Lorem.characters(36) }
    tenant_id       { FFaker::Guid.guid }
    resource_id     { FFaker::Internet.http_url }
    license_name    'O365_BUSINESS_PREMIUM'

    factory :staging_office365_instance do
      client_id       'cd329bba-1082-40a1-93e9-496370a53f18'
      client_secret   'sZp1HMkFBfPNjdPj3Qy5N563W4qVkz9eEqn49VErI6k='
      tenant_id       '01b78576-ce65-44db-841f-e2ea4c7c5db0'
      resource_id     'https://graph.windows.net'
    end
  end
end