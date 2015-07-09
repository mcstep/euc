require 'rails_helper'

RSpec.describe User, type: :model do
  it 'enqueues' do
    create(:user)
    expect(SignupWorker).to have(1).jobs
  end

  describe 'invitation' do
    subject(:invitation){ create :invitation }

    describe 'limit' do
      it 'reduces' do
        expect(invitation.from_user.invitations_used).to eq 1
      end

      it 'increases' do
        invitation.destroy!
        expect(invitation.from_user.reload.invitations_used).to eq 0
      end
    end

    context 'when limit is over' do
      subject do
        build :invitation, from_user: create(:user, total_invitations: 0)
      end

      it{ is_expected.to be_valid }
      it 'can not be saved' do
        expect(lambda{ subject.save! }).to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'profile' do
    context 'when invited' do
      let(:invitation){ Invitation.create! from_user: create(:user), to_user: build(:user, profile: nil) }
      subject{ invitation.to_user.profile_id }

      it{ is_expected.to eq invitation.from_user.profile_id }

      it 'sets authentication integration' do
        expect(invitation.to_user.reload.authentication_integration_id).to_not be_nil
      end
    end

    context 'when unset' do
      context 'having approved domain' do
        let!(:domain){ create(:domain, name: 'test.com') }
        subject{ create :user, profile: nil, email: 'user@test.com' }

        it 'inherits from domain' do
          expect(subject.profile_id).to eq domain.profile_id
        end
      end

      context 'not having approved domain' do
        subject{ lambda{create :user, profile: nil, email: 'user@test.com'} }

        it{ is_expected.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end

  describe 'integrations' do
    let(:external_integration){ create(:integration) }
    let(:profile){ create(:profile) }
    let(:profile_with_integrations) do
      profile.profile_integrations << build(:airwatch_profile_integration)
      profile.profile_integrations << build(:google_apps_profile_integration, authentication_priority: 0)
      profile
    end
    let(:google_apps_integration){ profile_with_integrations.profile_integrations.last }
    let(:user){ create(:user, profile: profile_with_integrations) }

    subject{ user.user_integrations }

    it{ is_expected.to have_exactly(3).items }

    it 'has airwatch enabled' do
      expect(subject.map(&:airwatch_disabled)).to eq [true, false, true]
    end

    it 'has google apps enabled' do
      expect(subject.map(&:google_apps_disabled)).to eq [true, true, false]
    end

    context 'when disabler specified' do
      subject do
        integration_ids = profile_with_integrations.profile_integrations.map(&:integration_id)

        user = create(:user,
          profile: profile_with_integrations,
          user_integrations_attributes: [
            {integration_id: integration_ids[1], airwatch_disabled: true},
            {integration_id: external_integration.id}
          ]
        )

        user.user_integrations
      end

      it{ is_expected.to have_exactly(3).items }

      it 'has airwatch disabled' do
        expect(subject.map(&:airwatch_disabled)).to eq [true, true, true]
      end

      it 'has google apps enabled' do
        expect(subject.map(&:google_apps_disabled)).to eq [true, true, false]
      end
    end

    context 'when meta provided' do
      subject do
        user = create :user, profile: profile_with_integrations,
          integrations_username: 'test',
          integrations_expiration_date: Date.tomorrow

        user.user_integrations
      end

      it 'inherits username' do
        expect(subject.map(&:directory_username)).to eq ['test']*3
      end

      it 'inherits expiration date' do
        expect(subject.map(&:directory_expiration_date)).to eq [Date.tomorrow]*3
      end
    end

    describe 'authentication' do
      subject{ user.authentication_integration.integration_id }

      it{ is_expected.to eq google_apps_integration.integration_id }
    end
  end
end