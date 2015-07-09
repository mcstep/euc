require 'rails_helper'

RSpec.describe Directory, :vcr, type: :model do
  let(:directory){ build :real_directory }

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
    after{ directory.unregister user_integration.directory_username }

    let(:user_integration){ create(:user_integration) }
    let(:username){ user_integration.directory_username }
    let(:password){ @response['password'] }

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
        expect(directory.unregister user_integration.directory_username).to eq nil
      end
    end

    describe '.prolong' do
      it 'works' do
        expect(directory.prolong user_integration.directory_username, Date.today).to eq nil
      end
    end

    describe '.add_group' do
      it 'works' do
        expect(directory.add_group user_integration.directory_username, 'SpecGroup').to eq nil
      end
    end

    describe '.remove_group' do
      it 'works' do
        expect(directory.add_group user_integration.directory_username, 'SpecGroup').to eq nil
      end
    end
  end
end