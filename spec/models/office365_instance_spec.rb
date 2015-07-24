require 'rails_helper'

RSpec.describe Office365Instance, :vcr, type: :model do
  let(:office365_instance){ create :staging_office365_instance }

  describe '.update_user' do
    it 'works' do
      expect{ office365_instance.update_user('o365.test@vmwdev.net', 'usageLocation' => 'US') }.to_not raise_error
    end

    it 'is idempotent' do
      expect{
        2.times{ office365_instance.update_user('o365.test@vmwdev.net', 'usageLocation' => 'US') }
      }.to_not raise_error
    end
  end

  describe '.assign_license' do
    it 'works' do
      expect{ office365_instance.assign_license('o365.test@vmwdev.net', 'O365_BUSINESS_PREMIUM') }.to_not raise_error
    end

    it 'is idempotent' do
      expect{
        2.times{ office365_instance.assign_license('o365.test@vmwdev.net', 'O365_BUSINESS_PREMIUM') }
      }.to_not raise_error
    end
  end

  describe '.update_password' do
    it 'works' do
      expect{ office365_instance.update_password('o365.test@vmwdev.net', 'test') }.to_not raise_error
    end

    it 'is idempotent' do
      expect{
        2.times{ office365_instance.update_password('o365.test@vmwdev.net', 'test') }
      }.to_not raise_error
    end
  end
end