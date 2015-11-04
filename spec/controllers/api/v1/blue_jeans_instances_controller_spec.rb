require "rails_helper"

RSpec.describe Api::V1::BlueJeansInstancesController, type: :controller do
  let(:user){ create(:root, can_edit_services: true) }
  let(:token){ double acceptable?: true, resource_owner_id: user.id }
  before{ allow(controller).to receive(:doorkeeper_token).and_return(token) }

  describe 'GET #index' do
    before{ create_list(:blue_jeans_instance, 5) }
    before{ get :index }
    subject{ response }

    it{ is_expected.to be_success }

    describe 'body' do
      subject{ response.body }

      it{ is_expected.to have_json_size(5).at_path('data') }
    end
  end

  describe 'POST #create' do
    let(:entity){ build(:blue_jeans_instance) }
    subject{ response }

    context 'when valid' do
      before{ post :create, id: entity.id, blue_jeans_instance: entity.attributes }
      it{ is_expected.to be_success }
    end

    context 'when invalid' do
      before{ post :create, id: entity.id, blue_jeans_instance: { client_id: '' } }
      it{ is_expected.to_not be_success }

      describe 'body' do
        subject{ response.body }

        it{ is_expected.to have_json_path('errors') }
      end
    end
  end

  describe 'PATCH #update' do
    let(:entity){ create(:blue_jeans_instance) }
    subject{ response }

    context 'when valid' do
      before{ patch :update, id: entity.id, blue_jeans_instance: { client_id: 'asdf' } }
      it{ is_expected.to be_success }
      it{ expect(entity.reload.client_id).to eq 'asdf' }
    end

    context 'when invalid' do
      before{ patch :update, id: entity.id, blue_jeans_instance: { client_id: '' } }
      it{ is_expected.to_not be_success }

      describe 'body' do
        subject{ response.body }

        it{ is_expected.to have_json_path('errors') }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:entity){ create(:blue_jeans_instance) }
    before{ delete :destroy, id: entity.id }
    subject{ response }
    it{ is_expected.to be_success }
    it{ expect(AirwatchInstance.where(id: entity.id).count).to eq 0 }
  end
end