require 'rails_helper'

RSpec.describe AirwatchGroup, type: :model do
  describe '#produce' do
    let(:user_integration){ FactoryGirl.create(:airwatch_user_integration) }
    subject{ AirwatchGroup.produce(user_integration) }
    before do 
      allow(user_integration.integration.airwatch_instance)
        .to receive(:add_group).and_return('Value' => 1)
    end

    it { expect{ subject }.to change{ AirwatchGroup.count }.by(1) }
    it { is_expected.to be_a AirwatchGroup }
    it { expect(subject.numeric_id).to eq '1' }

    context 'when exists' do
      before{ AirwatchGroup.produce(user_integration) }

      it { expect{ subject }.to change{ AirwatchGroup.count }.by(0) }
      it { is_expected.to be_a AirwatchGroup }
      it { expect(subject.numeric_id).to eq '1' }
    end
  end
end