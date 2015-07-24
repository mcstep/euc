FactoryGirl.define do
  factory :profile do
    name                  { FFaker::Lorem.words(2).join(' ') }
    profile_integrations  { [build(:profile_integration)] }
    supports_vidm         false

    factory :empty_profile do
      profile_integrations []
    end

    factory :full_profile do
      profile_integrations { [build(:directory_profile_integration)] }
    end

    factory :profile_with_groups do
      group_name    'test'
      group_region  'dldc'
      supports_vidm true
    end
  end
end