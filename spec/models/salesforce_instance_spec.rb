require 'rails_helper'

RSpec.describe SalesforceInstance, :vcr, type: :model do
  let(:salesforce_instance){ create :staging_salesforce_instance }

  describe '.register' do
    it 'works' do
      expect{ salesforce_instance.register('spec0', 'Spec', 'User', 'spec_________0@user.com') }.to_not raise_error
    end
  end

  describe '.update' do
    before{ @id = salesforce_instance.register('spec1', 'Spec', 'User', 'spec_________1@user.com') }

    it 'works' do
      expect{ salesforce_instance.update(@id, isactive: false) }.to_not raise_error
    end
  end
end