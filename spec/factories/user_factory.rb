FactoryGirl.define do
  factory :user do
    first_name  { FFaker::Name.first_name }
    last_name   { FFaker::Name.last_name }
    job_title   { FFaker::Job.title }
    email       { FFaker::Internet.email }
    home_region { %w(amer emea apac dldc).sample }
    role        :basic

    association :company, factory: :company, strategy: :build
    association :profile, factory: :profile, strategy: :build

    factory :empty_user do
      association :profile, factory: :empty_profile, strategy: :build
    end

    factory :real_user do
      integrations_username 'first.user'
      association :profile, factory: :real_profile, strategy: :build
    end

    factory :root do
      role :root
    end
  end
end