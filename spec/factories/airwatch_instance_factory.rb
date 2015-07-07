FactoryGirl.define do
  factory :airwatch_instance do
    group_name      'AirWatchUsers'
    group_region    'dldc'
    host            { FFaker::Internet.domain_name }
    api_key         { FFaker::Lorem.characters(20) }
    user            { FFaker::Internet.user_name }
    password        { FFaker::Internet.password }
    parent_group_id { rand(1...999) }
  end
end