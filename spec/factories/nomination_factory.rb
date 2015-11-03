FactoryGirl.define do
  factory :nomination do
    user          { create :user }
    company_name  { FFaker::Company.name }
    contact_name  { FFaker::Name.first_name }
    contact_email { FFaker::Internet.email }
    domain        { FFaker::Internet.domain_name }
  end
end