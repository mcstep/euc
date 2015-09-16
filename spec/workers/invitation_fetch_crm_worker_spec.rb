require 'rails_helper'

RSpec.describe InvitationFetchCrmWorker, type: :model do
  describe '.perform' do
    let(:instance){ FactoryGirl.create(:opportunities_staging_salesforce_instance) }
    let(:from_user){ FactoryGirl.create(:user, company: company) }
    subject{ InvitationFetchCrmWorker.new.perform(invitation.id) }

    context 'for salesforce dealregs' do
      let(:company){ FactoryGirl.create(:company, salesforce_dealreg_instance_id: instance.id) }
      let(:invitation) do
        FactoryGirl.create :invitation,
          from_user: from_user,
          crm_kind: :salesforce_dealreg,
          crm_id: 'ORTN-01368187'
      end

      context 'when no instance' do
        let(:company){ FactoryGirl.create(:company, salesforce_dealreg_instance_id: nil) }

        it 'works' do
          expect{ subject }.to_not raise_error
        end
      end

      context 'when id not found' do
        let(:invitation) do
          FactoryGirl.create :invitation,
            from_user: from_user,
            crm_kind: :salesforce_dealreg,
            crm_id: '999'
        end

        it 'works' do
          expect{ subject }.to raise_error(Exception)
          expect(invitation.reload.crm_fetch_error).to eq true
        end
      end

      it 'works', :vcr do
        expect{ subject }.to_not raise_error
        expect(invitation.reload.crm_data).to eq("Account Manager"=>"Sebastien Cassar", "Customer Name"=>"Michelin", "Sales Stage"=>"02 - Qualified", "Deal License ($)"=>0.0, "Segment"=>"T2", "Country"=>"FRANCE", "Forecast Status"=>"Upside")
        expect(invitation.reload.crm_fetch_error).to eq false
      end
    end

    context 'for salesforce opportunities' do
      let(:company){ FactoryGirl.create(:company, salesforce_opportunity_instance_id: instance.id) }
      let(:invitation) do
        FactoryGirl.create :invitation,
          from_user: from_user,
          crm_kind: :salesforce_opportunity,
          crm_id: '1073356'
      end

      it 'works', :vcr do
        expect{ subject }.to_not raise_error
        expect(invitation.reload.crm_data).to eq({"Account Manager"=>"Cameron Milek", "Sales Stage"=>"Pending Administrative Review", "Deal License ($)"=>50000.0, "Segment"=>"Government", "Customer Name"=>"Aus Inst of Health and Welfare", "Forecast Status"=>nil, "Country"=>"AUSTRALIA"})
        expect(invitation.reload.crm_fetch_error).to eq false
      end
    end
  end
end