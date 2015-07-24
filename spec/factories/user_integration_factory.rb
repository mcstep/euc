FactoryGirl.define do
  factory :user_integration do
    username                  { FFaker::Internet.user_name }
    directory_expiration_date { Date.tomorrow }

    association :user, factory: :empty_user, strategy: :build
    association :integration, factory: :integration, strategy: :build

    factory :airwatch_user_integration do
      association :integration, factory: :airwatch_integration, strategy: :build
    end

    factory :google_apps_user_integration do
      association :integration, factory: :google_apps_integration, strategy: :build
    end

    factory :complete_user_integration do
      association :integration, factory: :complete_integration, strategy: :build
    end
  end
end