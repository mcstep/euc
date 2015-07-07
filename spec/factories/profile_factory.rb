FactoryGirl.define do
  factory :profile do
    name                  { FFaker::Lorem.words(2).join(' ') }
    profile_integrations  { [build(:profile_integration)] }

    factory :empty_profile do
      profile_integrations []
    end

    factory :real_profile do
      profile_integrations { [build(:real_profile_integration)] }
    end
  end

  factory :profile_integration do
    allow_sharing true
    association :integration, factory: :integration, strategy: :build

    factory :real_profile_integration do
      association :integration, factory: :real_integration, strategy: :build
    end

    factory :airwatch_profile_integration do
      association :integration, factory: :airwatch_integration, strategy: :build
    end

    factory :google_apps_profile_integration do
      association :integration, factory: :google_apps_integration, strategy: :build
    end
  end
end