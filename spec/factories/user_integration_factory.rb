FactoryGirl.define do
  factory :user_integration do
    username                  { FFaker::Internet.user_name }
    directory_expiration_date { Date.tomorrow }

    association :user, factory: :user
    association :integration, factory: :integration

    factory :airwatch_user_integration do
      association :integration, factory: :airwatch_integration
    end

    factory :google_apps_user_integration do
      association :integration, factory: :google_apps_integration
    end

    factory :complete_user_integration do
      association :integration, factory: :complete_integration
    end
  end
end