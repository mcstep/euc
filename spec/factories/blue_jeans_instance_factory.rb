FactoryGirl.define do
  factory :blue_jeans_instance do
    group_name      'BlueJeansUsers'
    group_region    'dldc'
    grant_type      'client_credentials'
    client_id       { FFaker::Guid.guid }
    client_secret   { FFaker::Lorem.characters(36) }
    enterprise_id   { rand(111...999) }
    support_emails  { FFaker::Internet.email }

    factory :staging_blue_jeans_instance do
      client_id       '317d827mzi'
      client_secret   '45a8d216a0e644849d4542cbb4da0892'
      enterprise_id   8858
    end
  end
end