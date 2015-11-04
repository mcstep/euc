require "rails_helper"

RSpec.describe Api::V1::SupportRequestsController, type: :controller do
  let(:user){ create(:root, can_edit_services: true) }
  let(:token){ double acceptable?: true, resource_owner_id: user.id }
  before{ allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'POST #create' do
    subject{ response }

    before{ post :create, support_request: { body: 'test' } }
    it{ is_expected.to be_success }
  end
end