require 'rails_helper'

RSpec.describe SignupWorker, type: :model do
  let(:user){ create(:user) }
  let(:directory){ mock_model(Directory) }
  let(:username){ user.authentication_integration.username }

  describe '.perform' do
    before do
      allow(directory).to receive :_read_attribute
      user.authentication_integration.integration.directory = directory
    end

    context 'when things go well' do
      it 'works' do
        expect(directory).to receive(:signup).with(user.authentication_integration).and_return(
          'username' => username,
          'password' => 'test'
        )

        expect{ SignupWorker.new.perform(user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      context 'when profile has groups' do
        let(:user){ create(:user, profile: create(:profile_with_groups)) }

        it 'works' do
          allow(directory).to receive(:signup).with(user.authentication_integration).and_return(
            'username' => username,
            'password' => 'test'
          )
          expect(directory).to receive(:add_group).once.with(username, 'test')
          expect(directory).to receive(:add_group).once.with(username, 'VIDMUsers')
          expect(directory).to receive(:sync).once.with('dldc')

          expect{ SignupWorker.new.perform(user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end

    context 'when it fails on second step' do
      let(:user){ create(:user, profile: create(:profile_with_groups)) }

      it 'works' do
        expect(directory).to receive(:signup).once.with(user.authentication_integration).and_return(
          'username' => username,
          'password' => 'test'
        )
        expect(directory).to receive(:add_group).once.with(username, 'test').and_raise('error')
        expect(directory).to receive(:add_group).once.with(username, 'VIDMUsers')
        expect(directory).to receive(:add_group).once.with(username, 'test')
        expect(directory).to receive(:sync).once.with('dldc')
        expect(directory).to receive(:update_password).once.with(username, nil)

        expect{ SignupWorker.new.perform(user) }.to raise_error('error')
        expect{ SignupWorker.new.perform(user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end