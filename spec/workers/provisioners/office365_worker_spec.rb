require 'rails_helper'

RSpec.describe Provisioners::Office365Worker, type: :model do
  let(:user_integration) do
    create :user_integration, integration: create(:office365_integration), user: create(:full_user)
  end
  let(:instance){ mock_model(Office365Instance) }
  let(:directory){ mock_model(Directory) }
  let(:user){ user_integration.user }
  let(:username){ user_integration.username }

  def reload_user_integration
    user_integration.reload
    user_integration.integration.office365_instance = instance
    user_integration.integration.directory = directory
    user_integration
  end

  before do
    allow(instance).to receive(:group_name).and_return('group')
    allow(instance).to receive(:group_region).and_return('region')
  end

  describe '.provision' do
    before do
      allow(directory).to receive :_read_attribute
      allow(instance).to receive :_read_attribute
      user_integration.integration.office365_instance = instance
      user_integration.integration.directory = directory
    end

    it 'reenques' do
      expect{
        Provisioners::Office365Worker.new.perform(user_integration, :provision)
      }.to change { Provisioners::Office365Worker.jobs.length }.by(1)
    end

    context 'when user provisioned' do
      before do
        user_integration.user.authentication_integration.update_attributes(directory_status: :provisioned)
      end

      context 'when things go well' do
        it 'works' do
          expect(instance).to receive(:update_user).once.with("#{username}@#{user_integration.integration.domain}", 'usageLocation' => 'US')
          expect(instance).to receive(:assign_license).once
          expect(directory).to receive(:office365_sync).once.with(username, user_integration.integration.domain)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:replicate)
          expect(directory).to receive(:replicate).once.with('ad2')
          expect(directory).to receive(:sync).once.with('region')

          Provisioners::Office365Worker.new.perform(user_integration, :provision)
          expect(reload_user_integration.office365_status).to eq :provisioned
        end
      end

      context 'when it fails' do
        it 'works' do
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:replicate)
          expect(directory).to receive(:sync).once.with('region').and_raise('error')

          expect(directory).to receive(:office365_sync).once.with(username, user_integration.integration.domain)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:replicate)
          expect(directory).to receive(:replicate).once.with('ad2')
          expect(directory).to receive(:sync).once.with('region')
          expect(instance).to receive(:update_user).once.with("#{username}@#{user_integration.integration.domain}", 'usageLocation' => 'US')
          expect(instance).to receive(:assign_license).once

          expect{ Provisioners::Office365Worker.new.perform(user_integration, :provision) }.to raise_error('error')
          expect(reload_user_integration.office365_status).to_not eq :provisioned
          Provisioners::Office365Worker.new.perform(user_integration, :provision)
          expect(reload_user_integration.office365_status).to eq :provisioned
        end
      end
    end
  end

end