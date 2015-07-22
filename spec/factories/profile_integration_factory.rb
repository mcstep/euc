FactoryGirl.define do
  factory :profile_integration do
    allow_sharing true
    association :integration, factory: :integration, strategy: :build

    factory :directory_profile_integration do
      association :integration, factory: :directory_integration, strategy: :build
    end

    factory :airwatch_profile_integration do
      association :integration, factory: :airwatch_integration, strategy: :build
    end

    factory :google_apps_profile_integration do
      association :integration, factory: :google_apps_integration, strategy: :build
    end

    ##
    # Seeds
    ##
    factory :default_profile_integration do
      association :integration, factory: :airwatch_integration, strategy: :build
    end

    factory :apple_profile_integration do
      association :integration, factory: :google_apps_integration, strategy: :build
    end
  end
end