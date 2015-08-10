FactoryGirl.define do
  factory :profile_integration do
    allow_sharing true
    association :integration, factory: :integration
    association :profile, factory: :profile

    factory :directory_profile_integration do
      association :integration, factory: :directory_integration
    end

    factory :airwatch_profile_integration do
      association :integration, factory: :airwatch_integration
    end

    factory :google_apps_profile_integration do
      association :integration, factory: :google_apps_integration
    end

    ##
    # Seeds
    ##
    factory :default_profile_integration do
      association :integration, factory: :airwatch_integration
    end

    factory :apple_profile_integration do
      association :integration, factory: :google_apps_integration
    end
  end
end