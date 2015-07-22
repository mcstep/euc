FactoryGirl.define do
  factory :integration do
    name        { FFaker::Lorem.words(2).join(' ') }
    domain      { FFaker::Internet.domain_name }
    association :directory, factory: :directory, strategy: :build

    factory :directory_integration do
      association :directory, factory: :test_directory, strategy: :build
    end

    factory :airwatch_integration do
      association :airwatch_instance, factory: :airwatch_instance, strategy: :build
    end

    factory :google_apps_integration do
      association :google_apps_instance, factory: :google_apps_instance, strategy: :build
    end

    factory :complete_integration do
      association :airwatch_instance, factory: :airwatch_instance, strategy: :build
      association :google_apps_instance, factory: :google_apps_instance, strategy: :build
    end
  end
end