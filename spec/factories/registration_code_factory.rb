FactoryGirl.define do
  factory :registration_code do
    user_validity         { rand(1..10) }
    total_registrations   { rand(1..10) }
    profile               { create(:profile) }
  end
end