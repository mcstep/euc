require "rails_helper"

RSpec.describe Api::V1::InvitationsController, type: :controller do
  let(:root){ create(:root) }
  let(:token){ double acceptable?: true, resource_owner_id: root.id }
  before{ allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'POST #create' do
    subject{ response }

    context 'when valid' do
      before do
        post :create, invitation: { to_user_attributes: {
          first_name: 'First',
          last_name: 'Last',
          email: 'email@domain.zone',
          job_title: 'test',
          company_name: 'test',
          home_region: 'amer'
        }}
      end

      it{ is_expected.to be_success }
    end

    context 'when invalid' do
      before{ post :create, invitation: { hey: 'you' } }
      it{ is_expected.to_not be_success }
    end
  end
end