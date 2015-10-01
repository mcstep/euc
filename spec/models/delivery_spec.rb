require 'rails_helper'

RSpec.describe Delivery, :vcr, type: :model do
  let(:delivery) { build(:delivery) }

  describe 'saving' do
    it 'runs worker' do
      expect{delivery.save!}.to change{ DeliveryRunWorker.jobs.length }.by 1
    end
  end

  describe '.recipients' do
    let(:profile){ create :integrated_profile }
    let!(:profile_users){ create_list :user, 5, profile: profile }
    let!(:other_users){ create_list :user, 5 }

    it 'works' do
      expect(delivery.recipients.length).to eq 10
    end

    context 'with profile' do
      before{ delivery.profile = profile }

      it 'works' do
        expect(delivery.recipients.length).to eq 5
      end
    end
  end

  describe '.send!' do
    it 'works' do
      expect{ delivery.send! }.to_not raise_error
      expect(delivery.status).to eq :sent
    end
  end
end