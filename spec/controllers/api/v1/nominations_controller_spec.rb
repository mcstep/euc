require "rails_helper"

RSpec.describe Api::V1::NominationsController, type: :controller do
  let(:root){ create(:root) }
  let(:token){ double acceptable?: true, resource_owner_id: root.id }
  before{ allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'GET #index' do
    before{ create_list :nomination, 5 }
    before{ get :index }
    subject{ response }
    it{ is_expected.to be_success }

    describe 'body' do
      subject{ response.body }

      it{ is_expected.to have_json_size(5).at_path('data') }
    end
  end

  describe 'POST #create' do
    subject{ response }

    context 'when valid' do
      before do
        post :create, nomination: {
          contact_name: 'Test',
          contact_email: 'test@email.com',
          company_name: 'test',
          domain: 'domain.com'
        }
      end

      it{ is_expected.to be_success }
    end

    context 'when invalid' do
      before{ post :create, nomination: { hey: 'you' } }
      it{ is_expected.to_not be_success }
    end
  end

  describe 'POST #decline' do
    let(:nomination){ create :nomination }
    before{ post :decline, id: nomination.id }
    subject{ response }
    it{ is_expected.to be_success }
    it{ expect(nomination.reload.declined?).to eq true }
  end

  describe 'PATCH #update' do
    let(:nomination){ create :nomination }
    let(:profile){ create :profile }
    before{ patch :update, id: nomination.id, nomination: {profile_id: profile.id} }
    subject{ response }
    it{ is_expected.to be_success }
    it{ expect(nomination.reload.approved?).to eq true }
  end
end