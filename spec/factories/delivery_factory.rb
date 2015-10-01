FactoryGirl.define do
  factory :delivery do
    from_email  { FFaker::Internet.email }
    subject     { FFaker::Lorem.words(4).join(' ') }
    body        { FFaker::Lorem.words(20).join(' ') }
  end
end