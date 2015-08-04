FactoryGirl.define do
  factory :directory do
    host      { FFaker::Internet.domain_name }
    port      8080
    api_key   { FFaker::Lorem.characters(36) }

    factory :test_directory do
      host    'receiver.vmwdev.com'
      api_key '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
      use_ssl true
      port    443
    end
  end
end