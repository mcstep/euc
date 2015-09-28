require 'rails_helper'

RSpec::Matchers.define :enqueue_as do |kind|
  match do |worker|
    worker.jobs.length == 1 && worker.jobs.first['args'][1] == kind
  end
  failure_message do |worker|
    if worker.jobs.length != 1
      "expected exactly 1 job but got #{worker.jobs.length}"
    else
      "expected '#{kind}' job but got #{worker.jobs.first['args'][1]}"
    end
  end
end

RSpec.describe UserIntegration, type: :model do
  let(:user_integration){ create(:user_integration) }
  subject(:ui_with_disabled_services) do
    UserIntegration.new(
      # prohibit_google_apps: false, <- default value
      # prohibit_horizon_air: true,
      # prohibit_horizon_rds: true,
      prohibit_horizon_view: true,
      prohibit_airwatch: true,
      prohibit_office365: true
    )
  end

  describe '.email' do
    subject{ user_integration.email }
    it { expect{subject}.to_not raise_error }
  end

  describe '.airwatch_email' do
    subject{ user_integration.airwatch_email }
    it { expect{subject}.to_not raise_error }
  end

  describe '.*_disabled?' do
    it 'gets proper state' do
      ui_with_disabled_services.office365_status = :revoked
      expect(ui_with_disabled_services.office365_disabled?).to be_truthy
    end
  end

  describe '.prohibit_*=' do
    it 'defaults to false' do
      expect(ui_with_disabled_services.google_apps_disabled?).to be_falsey
    end

    it 'sets proper state' do
      expect(ui_with_disabled_services.office365_status == :disabled)
    end

    context 'when applied to enabled service' do
      it 'preserves state when no modification required' do
        ui_with_disabled_services.google_apps_status = :provisioned
        ui_with_disabled_services.prohibit_google_apps = false
        expect(ui_with_disabled_services.google_apps_status == :provisioned)
      end
    end

    context 'when applied to disabled service' do
      it 'preserves state when no modification required' do
        ui_with_disabled_services.office365_status = :revoked
        ui_with_disabled_services.prohibit_office365 = true
        expect(ui_with_disabled_services.google_apps_status == :revoked)
      end
    end
  end

  describe '.airwatch_group_name' do
    context 'when all set' do
      let(:airwatch_instance){ create(:airwatch_instance) }
      subject do
        UserIntegration.new(
          integration: build(:integration, airwatch_instance: airwatch_instance),
          user: User.new(email: 'foo@bar.com')
        ).airwatch_group_name
      end

      it{ is_expected.to eq "bar-com" }
    end

    context 'when some miss' do
      subject{ -> { UserIntegration.new.airwatch_group_name } }
      it{ is_expected.to raise_error(Exception) }
    end
  end

  describe 'provisioning' do
    let!(:user_integration){ create(:complete_user_integration) }

    describe 'bootstrap' do
      context 'when profile implies eula' do
        let!(:user_integration) do
          create :complete_user_integration,
              user: create(:user, profile: create(:integrated_profile, implied_airwatch_eula: true))
        end

        it 'does enque Airwatch provisioning' do
          expect(Provisioners::AirwatchWorker).to enqueue_as 'provision'
        end
      end

      it 'does not enque Airwatch provisioning' do
        expect(Provisioners::AirwatchWorker).to have(0).jobs
      end

      it 'enqueues Google Apps provisioning' do
        expect(Provisioners::GoogleAppsWorker).to enqueue_as 'provision'
      end

      it 'enqueues Horizon View provisioning' do
        expect(Provisioners::HorizonViewWorker).to enqueue_as 'provision'
      end

      it 'enqueues Blue Jeans provisioning' do
        expect(Provisioners::BlueJeansWorker).to enqueue_as 'provision'
      end
    end

    describe 'change' do
      before{ Sidekiq::Worker.clear_all }

      describe 'Airwatch' do
        let!(:user_integration){ create(:airwatch_user_integration) }

        subject{ Provisioners::AirwatchWorker }

        describe 'approve' do
          before{ user_integration.user.accept_airwatch_eula! }
          it{ is_expected.to enqueue_as 'provision' }
        end
      end

      describe 'Google Apps' do
        let!(:user_integration){ create(:google_apps_user_integration) }

        subject{ Provisioners::GoogleAppsWorker }

        context 'when provisioning' do
          it 'does not allow prohibiting' do
            expect(lambda{ user_integration.google_apps.prohibit }).to raise_error(MicroMachine::InvalidState)
          end

          it 'makes deprovisioning wait' do
            expect{ ProvisionerWorker.new.perform(user_integration.id, 'cleanup') }.to \
              change{ ProvisionerWorker.jobs.length }.by(1)
          end
        end

        context 'when revoking' do
          before{ user_integration.replace_status('google_apps', :revoking) }

          it 'makes cleanup wait' do
            expect{ ProvisionerWorker.new.perform(user_integration.id, 'cleanup') }.to \
              change{ ProvisionerWorker.jobs.length }.by(1)
          end
        end

        context 'when provisioned' do
          before{ user_integration.replace_status('google_apps', :provisioned) }

          describe 'prohibit' do
            before{ user_integration.google_apps.prohibit; user_integration.save! }
            it{ is_expected.to enqueue_as 'revoke' }
          end

          describe 'destroy' do
            it do
              expect{ user_integration.destroy! }.to \
                change{ ProvisionerWorker.jobs.length }.by(1)
            end

            context 'after worker' do
              before{ ProvisionerWorker.new.perform(user_integration.id, 'cleanup') }
              it{ is_expected.to enqueue_as 'revoke' }
            end
          end
        end

        context 'when revoked' do
          before{ user_integration.replace_status('google_apps', :revoked) }

          describe 'resume' do
            before{ user_integration.google_apps.toggle; user_integration.save! }
            it{ is_expected.to enqueue_as 'resume' }
          end

          describe 'destroy' do
            it do
              expect{ user_integration.destroy! }.to \
                change{ ProvisionerWorker.jobs.length }.by(1)
            end

            context 'after worker' do
              before{ ProvisionerWorker.new.perform(user_integration.id, 'cleanup') }
              it{ is_expected.to enqueue_as 'deprovision' }
            end
          end
        end

        context 'when revoking' do
          before{ user_integration.replace_status('google_apps', :revoking) }

          describe 'resume' do
            before{ user_integration.google_apps.complete_application; user_integration.save! }
            it{ expect(user_integration.google_apps_status).to eq :revoked }
          end

          context 'when removed' do
            before{ user_integration.update_attributes(deleted_at: DateTime.now) }

            describe 'resume' do
              before{ user_integration.google_apps.complete_application; user_integration.save! }
              it{ is_expected.to enqueue_as 'deprovision' }
            end
          end
        end
      end
    end
  end
end