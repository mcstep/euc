require 'rails_helper'

RSpec.describe AirwatchInstance, :vcr, type: :model do
  let(:airwatch_instance){ build :test_airwatch_instance }

  describe '.add_group' do
    subject{ @result = airwatch_instance.add_group('spec') }
    after{ airwatch_instance.delete_group(@result['Value']) }
    it{ is_expected.to be_a Hash }
  end

  describe '.add_user' do
    subject{ @result = airwatch_instance.add_user('spec.test') }
    after{ airwatch_instance.delete_user(@result['Value']) }
    it{ is_expected.to be_a Hash }
  end

  describe '.add_admin_user' do
    subject{ @result = airwatch_instance.add_admin_user('spec.test') }
    after{ airwatch_instance.delete_user(@result['Value']) }
    xit{ is_expected.to be_a Hash }
  end

  xdescribe 'with existing admin user' do
    before{ @result = airwatch_instance.add_admin_user('spec.test') }
    after{ airwatch_instance.delete_admin_user(@result['Value']) if @result }
    let(:admin_user_id){ @result['Value'] }

    describe '.delete_admin_user' do
      subject{ airwatch_instance.delete_admin_user(admin_user_id) }
      after{ @result = nil }
      it{ is_expected.to eq nil }

      it 'is idempotent' do
        attempt = lambda{ 2.times{ airwatch_instance.delete_admin_user(admin_user_id) } }
        expect(attempt).to_not raise_error
      end
    end
  end

  describe 'with existing user' do
    before{ @result = airwatch_instance.add_user('spec.test') }
    after{ airwatch_instance.delete_user(@result['Value']) if @result }
    let(:user_id){ @result['Value'] }

    describe '.deactivate' do
      subject{ airwatch_instance.deactivate(user_id) }
      it{ is_expected.to eq nil }

      it 'is idempotent' do
        attempt = lambda{ 2.times{ airwatch_instance.deactivate(user_id) } }
        expect(attempt).to_not raise_error
      end
    end

    describe '.activate' do
      before{ airwatch_instance.deactivate(user_id) }
      subject{ airwatch_instance.activate(user_id) }
      it{ is_expected.to eq nil }

      it 'is idempotent' do
        attempt = lambda{ 2.times{ airwatch_instance.activate(user_id) } }
        expect(attempt).to_not raise_error
      end
    end

    describe '.delete_user' do
      subject{ airwatch_instance.delete_user(user_id) }
      after{ @result = nil }
      it{ is_expected.to eq nil }

      it 'is idempotent' do
        attempt = lambda{ 2.times{ airwatch_instance.delete_user(user_id) } }
        expect(attempt).to_not raise_error
      end
    end
  end
end