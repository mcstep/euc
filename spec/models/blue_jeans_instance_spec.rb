require 'rails_helper'

RSpec.describe BlueJeansInstance, :vcr, type: :model do
  let(:blue_jeans_instance){ create :staging_blue_jeans_instance }

  describe '.title' do
    subject{ blue_jeans_instance.title }
    it { expect{subject}.to_not raise_error }
  end

  describe '.token' do
    subject{ blue_jeans_instance.token }

    it{ expect(subject.length).to eq 32 }
  end

  context 'with existing user' do
    before{ @id = blue_jeans_instance.register('spec', 'Spec', 'User', 'spec4@user.com', 'VMWare') }
    after{ blue_jeans_instance.unregister(@id) if @id }

    describe '.unregister' do
      it 'works' do
        expect{ blue_jeans_instance.unregister(@id) }.to_not raise_error
        @id = false
      end
    end

    describe '.create_default_settings' do
      it 'works' do
        expect{ blue_jeans_instance.create_default_settings(@id) }.to_not raise_error
      end
    end
  end
end