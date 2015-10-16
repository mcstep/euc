FactoryGirl.define do
  factory :profile do
    name                  { FFaker::Lorem.words(3).join(' ') }
    supports_vidm         false

    factory :integrated_profile do
      after(:create) do |profile|
        create_list(:profile_integration, 1, profile: profile)
      end

      factory :integrated_profile_with_groups do
        group_name    'test'
        group_region  'dldc'
        supports_vidm true
      end
    end

    factory :full_profile do
      after(:create) do |profile|
        create_list(:directory_profile_integration, 1, profile: profile)
      end
    end
  end
end