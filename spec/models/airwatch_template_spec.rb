require 'rails_helper'

RSpec.describe AirwatchTemplate, :vcr, type: :model do
  let(:airwatch_instance){ create :staging_airwatch_instance }
  let(:user_integration) do
    create :airwatch_user_integration,
      user:         create(:user, company_name: 'ZOMG Company 2', email: 'foo@pagac.name'),
      integration:  create(:integration, domain: 'spec65.com', airwatch_instance: airwatch_instance)
  end
  let(:airwatch_template){ AirwatchTemplate.produce(user_integration) }

  describe '.produce' do
    subject{ airwatch_template.data['organizationGroups'] }

    it{ expect{subject}.to change{ AirwatchTemplate.count }.by 1 }
    it{ is_expected.to include('name' => 'ZOMG Company 2 (pagac.name)') }

    context 'when exists' do
      before{ AirwatchTemplate.produce(user_integration) }
      it{ expect{subject}.to change{ AirwatchTemplate.count }.by 0 }
      it{ is_expected.to include('name' => 'ZOMG Company 2 (pagac.name)') }
    end
  end

  describe '.exist?' do
    subject{ AirwatchTemplate.exist?(user_integration) }
    it{ is_expected.to eq false }
  end

  describe '.to_h' do
    subject{ airwatch_template.to_h }
    it{ is_expected.to include("ZOMG Company 2 (pagac.name)" => 3921) }
  end
end