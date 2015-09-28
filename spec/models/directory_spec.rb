require 'rails_helper'

RSpec.describe Directory, :vcr, type: :model do
  let(:directory){ build :test_directory }

  describe '.title' do
    subject{ directory.title }
    it { expect{subject}.to_not raise_error }
  end

  describe '.office365_sync_all' do
    subject{ directory.office365_sync_all }
    it { expect{subject}.to_not raise_error }
  end

  describe '.office365_sync' do
    subject{ directory.office365_sync('username') }
    it { expect{subject}.to_not raise_error }
  end

  describe '.replicate' do
    subject{ directory.replicate }

    it { expect{subject}.to_not raise_error }
  end

  describe '.sync' do
    it 'works' do
      expect(directory.sync 'dldc').to eq 'dldc sync successfull!'
    end
  end

  describe '.signup' do
    let(:user_integration){ create(:user_integration) }
    subject{ directory.signup user_integration }
    after{ directory.unregister user_integration.username }

    it 'returns password' do
      expect(subject['password']).to be_a String
    end

    it 'is idempotent' do
      expect{ directory.signup user_integration }.to_not raise_error
      expect{ subject }.to_not raise_error
      expect(subject['password']).to be_a String
    end
  end

  context 'with_existing_user' do
    before{ @response = directory.signup user_integration }
    after{ directory.unregister username }

    let(:user_integration){ create(:user_integration) }
    let(:username){ user_integration.username }
    let(:password){ @response['password'] }
    let(:user) { user_integration.user }

    describe '.authenticate' do
      it 'fails with incorrect credentials' do
        expect(directory.authenticate username, 'ololo').to be_falsey
      end

      it 'approves correct credentials' do
        expect(directory.authenticate username, password).to be_truthy
      end
    end

    describe '.update_password' do
      it 'sets given password' do
        expect(directory.update_password username, 'Good4password').to eq 'Good4password'
      end

      it 'sets random password' do
        expect(directory.update_password username).to be_a String
      end
    end

    describe '.unregister' do
      it 'works' do
        expect(directory.unregister username).to eq 'OK'
      end
    end

    describe '.prolong' do
      it 'works' do
        expect(directory.prolong username, Date.today).to eq 'Success'
      end
    end

    describe '.add_group' do
      it 'works' do
        expect(directory.add_group username, 'SpecGroup').to eq 'Success'
      end

      xit 'is idempotent' do
        expect(directory.add_group username, 'SpecGroup').to eq 'Success'
        expect(directory.add_group username, 'SpecGroup').to eq 'Success'
      end
    end

    describe '.remove_group' do
      it 'works' do
        directory.add_group username, 'SpecGroup'
        expect(directory.remove_group username, 'SpecGroup').to eq 'Success'
      end

      xit 'is idempotent' do
        expect(directory.remove_group username, 'SpecGroup').to eq 'Success'
      end
    end

    describe '.create_profile' do
      it 'works' do
        expect(directory.create_profile username, user.home_region).to eq 'Success'
      end

      it 'is idempotent' do
        directory.create_profile username, user.home_region
        expect(directory.create_profile username, user.home_region).to eq 'Success'
      end
    end
  end
end