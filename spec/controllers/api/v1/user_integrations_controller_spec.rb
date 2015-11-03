require "rails_helper"

RSpec.describe Api::V1::UserIntegrationsController, type: :controller do
  let(:user){ create(:root) }
  let(:token){ double acceptable?: true, resource_owner_id: user.id }
  before{ allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'POST #toggle' do
    let(:user_integration){ create(:full_user).user_integrations.first }
    before{ post :toggle, id: user_integration.id, service: :airwatch }
    subject{ response }

    it{ is_expected.to be_success }
  end
end