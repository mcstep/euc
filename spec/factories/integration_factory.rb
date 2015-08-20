FactoryGirl.define do
  factory :integration do
    name        { FFaker::Lorem.words(2).join(' ') }
    domain      { FFaker::Internet.domain_name }
    association :directory, factory: :directory

    factory :directory_integration do
      association :directory, factory: :test_directory
    end

    factory :airwatch_integration do
      association :airwatch_instance, factory: :airwatch_instance
    end

    factory :google_apps_integration do
      association :google_apps_instance, factory: :google_apps_instance
    end

    factory :horizon_view_integration do
      association :horizon_view_instance, factory: :horizon_instance
    end

    factory :office365_integration do
      association :office365_instance, factory: :office365_instance
    end

    factory :blue_jeans_integration do
      association :blue_jeans_instance, factory: :blue_jeans_instance
    end

    factory :complete_integration do
      association :airwatch_instance, factory: :airwatch_instance
      association :google_apps_instance, factory: :google_apps_instance
      association :horizon_view_instance, factory: :horizon_instance
      association :blue_jeans_instance, factory: :blue_jeans_instance
    end
  end
end