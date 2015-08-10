FactoryGirl.define do
  factory :domain do
    name        { FFaker::Internet.domain_name }
    association :profile, factory: :integrated_profile
  end
end