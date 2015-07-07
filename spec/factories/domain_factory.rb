FactoryGirl.define do
  factory :domain do
    name      { FFaker::Internet.domain_name }

    association :profile, factory: :profile, strategy: :build
  end
end