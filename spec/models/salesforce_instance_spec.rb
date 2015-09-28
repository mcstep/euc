require 'rails_helper'

RSpec.describe SalesforceInstance, :vcr, type: :model do
  let(:salesforce_instance){ create :staging_salesforce_instance }

  describe '.title' do
    subject{ salesforce_instance.title }
    it { expect{subject}.to_not raise_error }
  end

  xdescribe '.fetch_crm_data' do
    context 'for SF dealregs' do
      subject{ salesforce_instance.fetch_crm_data(:salesforce_dealreg, '123') }
      it { expect{subject}.to_not raise_error }
    end
  end


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

  describe 'opportunities' do
    let(:salesforce_instance){ create :opportunities_staging_salesforce_instance }

    describe '.find_changed_deal_registrations' do
      it 'works' do
        expect(salesforce_instance.find_changed_dealregs).to eq ['1000']
      end

      context 'when timeout' do
        before do
          allow(salesforce_instance).to receive(:client).and_raise(Faraday::TimeoutError)
        end

        it 'works' do
          expect(salesforce_instance.find_changed_dealregs).to eq []
        end
      end
    end

    describe '.find_changed_opportunities' do
      it 'works' do
        expect(salesforce_instance.find_changed_opportunities).to eq []
      end

      context 'when timeout' do
        before do
          allow(salesforce_instance).to receive(:client).and_raise(Faraday::TimeoutError)
        end

        it 'works' do
          expect(salesforce_instance.find_changed_opportunities).to eq []
        end
      end
    end
  end
end