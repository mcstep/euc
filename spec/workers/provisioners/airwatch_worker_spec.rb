require 'rails_helper'

RSpec.describe Provisioners::AirwatchWorker, type: :model do
  let(:user_integration) do
    create :user_integration,
      integration: create(:airwatch_integration),
      user: create(:user,
          airwatch_eula_accept_date: Date.today,
          profile: create(:integrated_profile))
  end
  let(:instance){ mock_model(AirwatchInstance) }
  let(:directory){ mock_model(Directory) }
  let(:username){ user_integration.username }

  def reload_user_integration
    user_integration.reload
    user_integration.integration.airwatch_instance = instance
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
      reload_user_integration
    end

    it 'reenques' do
      expect{
        Provisioners::AirwatchWorker.new.perform(user_integration, :provision)
      }.to change { Provisioners::AirwatchWorker.jobs.length }.by(1)
    end

    context 'when user provisioned' do
      before do
        user_integration.user.authentication_integration.update_attributes(directory_status: :provisioned)
      end

      context 'when used in conjuction with google apps' do
        let(:user_integration) do
          create :complete_user_integration,
            user: create(:user,
              airwatch_eula_accept_date: Date.today,
              profile: create(:integrated_profile))
        end

        it 'reenques' do
          expect{
            Provisioners::AirwatchWorker.new.perform(user_integration, :provision)
          }.to change { Provisioners::AirwatchWorker.jobs.length }.by(1)
        end

        context 'when google apps finished provisioning' do
          before do
            user_integration.update_attributes(google_apps_status: :provisioned)
          end

          it 'works' do
            expect(instance).to receive(:add_user).once.with(username).and_return('Value' => 1)
            expect(instance).to receive(:use_admin).once.and_return(true)
            expect(instance).to receive(:use_groups).twice.and_return(true)
            expect(instance).to receive(:add_admin_user).once.with(user_integration).and_return('Value' => 1)
            expect(instance).to receive(:add_group).once.with(user_integration.airwatch_group_name).and_return('Value' => 1)
            expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
            expect(directory).to receive(:sync).once.with('region')
            expect(Cloudinary::Uploader).to receive(:upload).once.and_return('url' => '')

            expect{
              Provisioners::AirwatchWorker.new.perform(user_integration, :provision)
            }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end
      end

      context 'when things go well' do
        it 'works' do
          expect(instance).to receive(:add_user).once.with(username).and_return('Value' => 1)
          expect(instance).to receive(:use_admin).once.and_return(true)
          expect(instance).to receive(:add_admin_user).once.with(user_integration).and_return('Value' => 1)
          expect(instance).to receive(:use_groups).twice.and_return(true)
          expect(instance).to receive(:add_group).once.with(user_integration.airwatch_group_name).and_return('Value' => 1)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.with('region')
          expect(Cloudinary::Uploader).to receive(:upload).once.and_return('url' => '')

          expect{
            Provisioners::AirwatchWorker.new.perform(user_integration, :provision)
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(reload_user_integration.airwatch_status).to eq :provisioned
        end
      end

      context 'when admin username creation fails' do
        it 'works' do
          expect(instance).to receive(:add_user).once.with(username).and_return('Value' => 1)
          expect(instance).to receive(:use_admin).once.and_return(true)
          expect(instance).to receive(:add_admin_user).once.with(user_integration).and_raise('error')

          expect(instance).to receive(:use_admin).once.and_return(true)
          expect(instance).to receive(:add_admin_user).once.with(user_integration).and_return('Value' => 1)
          expect(instance).to receive(:use_groups).twice.and_return(true)
          expect(instance).to receive(:add_group).once.with(user_integration.airwatch_group_name).and_return('Value' => 1)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.with('region')
          expect(Cloudinary::Uploader).to receive(:upload).once.and_return('url' => '')

          expect{ Provisioners::AirwatchWorker.new.perform(user_integration, :provision) }.to raise_error('error')
          expect(reload_user_integration.airwatch_status).to_not eq :provisioned
          expect{
            Provisioners::AirwatchWorker.new.perform(user_integration, :provision)
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(reload_user_integration.airwatch_status).to eq :provisioned
        end
      end

      context 'when sync fails' do
        it 'works' do
          expect(instance).to receive(:add_user).once.with(username).and_return('Value' => 1)
          expect(instance).to receive(:use_admin).once.and_return(true)
          expect(instance).to receive(:add_admin_user).once.with(user_integration).and_return('Value' => 1)
          expect(instance).to receive(:use_groups).once.and_return(true)
          expect(instance).to receive(:add_group).once.with(user_integration.airwatch_group_name).and_return('Value' => 1)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.and_raise('error')

          expect(instance).to receive(:use_admin).once.and_return(true)
          expect(instance).to receive(:add_group).once.with(user_integration.airwatch_group_name).and_return('Value' => 1)
          expect(instance).to receive(:use_groups).twice.and_return(true)
          expect(directory).to receive(:add_group).once.with(username, 'group', user_integration.integration.domain)
          expect(directory).to receive(:sync).once.with('region')
          expect(Cloudinary::Uploader).to receive(:upload).once.and_return('url' => '')

          expect{ Provisioners::AirwatchWorker.new.perform(user_integration, :provision) }.to raise_error('error')
          expect(reload_user_integration.airwatch_status).to_not eq :provisioned

          expect{
            Provisioners::AirwatchWorker.new.perform(reload_user_integration, :provision)
          }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(reload_user_integration.airwatch_status).to eq :provisioned
        end
      end
    end
  end

end