require 'rails_helper'

RSpec.describe AirwatchInstance, :vcr, type: :model do
  let(:user_integration){ build :user_integration, username: 'spec.test' }
  let(:airwatch_instance){ build :staging_airwatch_instance }

  describe '.generate_template' do
    subject{ airwatch_instance.generate_template('spec7.com', 'company7') }
    it{ is_expected.to include('name' => 'company7') }

    context 'when called twice' do
      before{ airwatch_instance.generate_template('spec7.com', 'company7') }
      it{ is_expected.to include('name' => 'company7') }
    end
  end

  describe '.effective_admin_roles' do
    let(:airwatch_instance) do
      build :staging_airwatch_instance,
        use_templates: true
    end
    let(:user_integration) do
      ui = build :airwatch_user_integration
      ui.user = build :user, company_name: 'ZOMG Company 3'
      ui.integration.domain = 'spec8.com'
      ui.integration.airwatch_instance = airwatch_instance
      ui
    end

    before do
      airwatch_instance.update_attributes(
        admin_roles: [ {
          "Id" => "1", 
          "LocationGroupId"=> "ZOMG Company 3 (#{user_integration.user.email_domain})"
        } ]
      )
    end

    subject{ airwatch_instance.effective_admin_roles(user_integration) }

    it{ is_expected.to eq [{"Id"=>"1", "LocationGroupId"=>"3847"}] }
  end

  describe '.add_group' do
    subject{ @result = airwatch_instance.add_group('spec2') }
    after{ airwatch_instance.delete_group(@result['Value']) }
    it{ is_expected.to be_a Hash }
  end

  describe '.add_user' do
    subject{ @result = airwatch_instance.add_user('spec.test') }
    after{ airwatch_instance.delete_user(@result['Value']) }
    it{ is_expected.to be_a Hash }
  end

  describe '.add_admin_user' do
    subject{ @result = airwatch_instance.add_admin_user(user_integration) }
    after{ airwatch_instance.delete_admin_user(@result['Value']) }
    it{ is_expected.to be_a Hash }
  end

  describe 'with existing admin user' do
    before{ @result = airwatch_instance.add_admin_user(user_integration) }
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