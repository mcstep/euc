FactoryGirl.define do
  factory :profile do
    name                  { FFaker::Lorem.words(2).join(' ') }
    profile_integrations  { [build(:profile_integration)] }

    factory :empty_profile do
      profile_integrations []
    end

    factory :full_profile do
      profile_integrations { [build(:directory_profile_integration)] }
    end
  end
end