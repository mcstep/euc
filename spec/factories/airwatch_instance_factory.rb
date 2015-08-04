FactoryGirl.define do
  factory :airwatch_instance do
    group_name      'AirWatchUsers'
    group_region    'dldc'
    host            { FFaker::Internet.domain_name }
    api_key         { FFaker::Lorem.characters(20) }
    user            { FFaker::Internet.user_name }
    password        { FFaker::Internet.password }
    parent_group_id { rand(1...999) }
    admin_roles     [ {"Id" => "87", "LocationGroupId"=> "570" } ]
    security_pin    { rand(1111...9999) }

    factory :staging_airwatch_instance do
      host            'airwatch.vmwdev.com'
      api_key         'UIZaNu6vmqxFf3MKAxslgOK9fJOJfyH757xuvbRLvNs='
      user            'api.admin'
      password        'vmwareHelp!'
      parent_group_id 570
      security_pin    1111
    end
  end
end