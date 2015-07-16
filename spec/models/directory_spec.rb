require 'rails_helper'

RSpec.describe Directory, :vcr, type: :model do
  let(:directory){ build :real_directory }

  describe '.replicate' do
    subject{ directory.replicate }

    xit { is_expected.to_not raise_error }
  end

  describe '.sync' do
    it 'works' do
      expect(directory.sync 'dldc').to eq nil
    end
  end

  describe '.signup' do
    let(:user_integration){ create(:user_integration) }
    subject{ directory.signup user_integration }
    after{ directory.unregister user_integration.directory_username }

    it 'returns password' do
      expect(subject['password']).to be_a String
    end
  end

  context 'with_existing_user' do
    before{ @response = directory.signup user_integration }
    after{ directory.unregister username }

    let(:user_integration){ create(:user_integration) }
    let(:username){ user_integration.directory_username }
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

    describe '.unregister' do
      it 'works' do
        expect(directory.unregister username).to eq nil
      end
    end

    describe '.prolong' do
      it 'works' do
        expect(directory.prolong username, Date.today).to eq nil
      end
    end

    describe '.add_group' do
      it 'works' do
        expect(directory.add_group username, 'SpecGroup').to eq nil
      end

      xit 'is idempotent' do
        expect(directory.add_group username, 'SpecGroup').to eq nil
        expect(directory.add_group username, 'SpecGroup').to eq nil
      end
    end

    describe '.remove_group' do
      xit 'works' do
        directory.add_group username, 'SpecGroup'
        expect(directory.remove_group username, 'SpecGroup').to eq nil
      end

      xit 'is idempotent' do
        expect(directory.remove_group username, 'SpecGroup').to eq nil
      end
    end

    describe '.create_profile' do
      it 'works' do
        expect(directory.create_profile username, user.home_region).to eq nil
      end

      it 'is idempotent' do
        directory.create_profile username, user.home_region
        expect(directory.create_profile username, user.home_region).to eq nil
      end
    end
  end
end