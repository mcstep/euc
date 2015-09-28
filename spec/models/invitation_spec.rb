require 'rails_helper'

RSpec.describe Invitation, :vcr, type: :model do
  describe '.from' do
    let(:user){ create(:user) }
    subject{ Invitation.from(user) }
    it { expect{subject}.to_not raise_error }
  end

  describe '.free_invitation_point!' do
    subject{ create(:invitation).free_invitation_point! }
    it { expect{subject}.to_not raise_error }
  end

  describe 'crm fetching' do
    it 'enqueues by creation' do
      expect{
        FactoryGirl.create(:invitation, crm_kind: :salesforce_dealreg, crm_id: '123') 
      }.to change{ InvitationFetchCrmWorker.jobs.length }.by(1)
    end

    it 'enqueues by company modification' do
      company    = FactoryGirl.create(:company)
      invitation = FactoryGirl.create(:invitation,
        crm_kind: :salesforce_dealreg,
        crm_id: '123',
        from_user: FactoryGirl.create(:user, company: company)
      )
      expect{
        company.update_attributes(salesforce_dealreg_instance_id: FactoryGirl.create(:salesforce_instance).id)
      }.to change { InvitationFetchCrmWorker.jobs.length }.by(1)
    end
  end
end
