FactoryGirl.define do
  factory :directory do
    host      { FFaker::Internet.domain_name }
    port      8080
    api_key   { FFaker::Lorem.characters(36) }

    factory :real_directory do
      host    'staging.vmwdemo.com'
      api_key '7Fbi6tD0uzPa0Yfc7A7Lqv0992Zi5d3p'
    end
  end
end