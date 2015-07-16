FactoryGirl.define do
  factory :airwatch_instance do
    group_name      'AirWatchUsers'
    group_region    'dldc'
    host            { FFaker::Internet.domain_name }
    api_key         { FFaker::Lorem.characters(20) }
    user            { FFaker::Internet.user_name }
    password        { FFaker::Internet.password }
    parent_group_id { rand(1...999) }

    factory :real_airwatch_instance do
      host            'airwatch.vmwdev.com'
      api_key         'UIZaNu6vmqxFf3MKAxslgOK9fJOJfyH757xuvbRLvNs='
      user            'api.admin'
      password        'vmwareHelp!'
      parent_group_id  570
    end
  end
end