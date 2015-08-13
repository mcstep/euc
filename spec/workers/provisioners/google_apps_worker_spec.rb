require 'rails_helper'

RSpec.describe Provisioners::GoogleAppsWorker, type: :model do
  let(:user_integration) do
    create :user_integration, integration: create(:google_apps_integration), user: create(:full_user)
  end
  let(:instance){ mock_model(GoogleAppsInstance) }
  let(:directory){ mock_model(Directory) }
  let(:user){ user_integration.user }
  let(:username){ user_integration.username }

  def reload_user_integration
    user_integration.reload
    user_integration.integration.google_apps_instance = instance
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
      user_integration.integration.google_apps_instance = instance
      user_integration.integration.directory = directory
    end

    it 'reenques' do
      expect{
        Provisioners::GoogleAppsWorker.new.perform(user_integration, :provision)
      }.to change { Provisioners::GoogleAppsWorker.jobs.length }.by(1)
    end

    context 'when user provisioned' do
      before do
        user_integration.user.authentication_integration.update_attributes(directory_status: :provisioned)
      end

      context 'when things go well' do
        it 'works' do
          expect(instance).to receive(:register).once.with("#{username}@#{user_integration.integration.domain}", user.first_name, user.last_name)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.with('region')

          Provisioners::GoogleAppsWorker.new.perform(user_integration, :provision)
          expect(reload_user_integration.google_apps_status).to eq :provisioned
        end
      end

      context 'when it fails' do
        it 'works' do
          expect(instance).to receive(:register).once.with("#{username}@#{user_integration.integration.domain}", user.first_name, user.last_name)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.with('region').and_raise('error')

          expect(instance).to receive(:register).once.with("#{username}@#{user_integration.integration.domain}", user.first_name, user.last_name)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.with('region')

          expect{ Provisioners::GoogleAppsWorker.new.perform(user_integration, :provision) }.to raise_error('error')
          expect(reload_user_integration.google_apps_status).to_not eq :provisioned
          Provisioners::GoogleAppsWorker.new.perform(user_integration, :provision)
          expect(reload_user_integration.google_apps_status).to eq :provisioned
        end
      end
    end
  end

end