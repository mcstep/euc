FactoryGirl.define do
  factory :invitation do
    association :from_user, factory: :user, strategy: :build
    association :to_user,   factory: :user, strategy: :build, profile: nil
    sent_at     { DateTime.now }
  end
end