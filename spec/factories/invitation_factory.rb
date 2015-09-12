FactoryGirl.define do
  factory :invitation do
    association :from_user, factory: :user
    association :to_user,   factory: :user, strategy: :build, profile: nil
    sent_at     { DateTime.now }

    factory :opportunity_invitation do
      crm_id    '123'
      crm_kind  { CrmConfigurator.kinds.keys.sample }
      crm_data  { {fetched: true} }
    end
  end
end