require "rails_helper"

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user){ create(:root) }
  let(:token){ double acceptable?: true, resource_owner_id: user.id }
  before{ allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'GET #index' do
    before{ create_list(:user, 5) }
    before{ get :index }
    subject{ response }

    it{ is_expected.to be_success }

    describe 'body' do
      subject{ response.body }

      it{ is_expected.to have_json_size(5).at_path('data') }
      it{ is_expected.to have_json_size(10).at_path('included') }
    end
  end

  describe 'PATCH #update' do
    let(:entity){ create(:user) }
    subject{ response }

    context 'when valid' do
      before{ patch :update, id: entity.id, user: { first_name: 'test' } }
      it{ is_expected.to be_success }
      it{ expect(entity.reload.first_name).to eq 'test' }
    end

    context 'when invalid' do
      before{ patch :update, id: entity.id, user: { first_name: '' } }
      it{ is_expected.to_not be_success }

      describe 'body' do
        subject{ response.body }

        it{ is_expected.to have_json_path('errors') }
      end
    end
  end

  describe 'POST #recover' do
    let(:entity){ create(:user) }
    before{ entity.authentication_integration.update_attributes(directory_status: :provisioned) }
    before{ post :recover, id: entity.id }
    subject{ response }
    it{ is_expected.to be_success }
  end

  describe 'DELETE #destroy' do
    let(:entity){ create(:user) }
    before{ delete :destroy, id: entity.id }
    subject{ response }
    it{ is_expected.to be_success }
    it{ expect(User.where(id: entity.id).count).to eq 0 }
  end
end