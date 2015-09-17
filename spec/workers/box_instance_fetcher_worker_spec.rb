require 'rails_helper'

RSpec.describe BoxInstanceFetcherWorker, :vcr, type: :model do
  let(:instance){ FactoryGirl.create(:staging_box_instance) }
  let(:worker){ BoxInstanceFetcherWorker.new(instance.id) }

  describe '.login_to_token_generator' do
    it 'works' do
      expect(worker.login_to_token_generator.link_with(href: '/logout')).to_not eq nil
    end
  end

  describe '.perform' do
    before{ worker.perform }
    it 'works' do
      expect(instance.reload.access_token).to eq 'QZUM4G8nqYL5osC8PJOnwB8YruBv37Ot'
      expect(instance.reload.refresh_token).to eq 'U0gmdLj6v281ahzlq2smaiXdm6mqXFYZsuzeeeElg4Eotl3xVOBZoAqJ99UqdMrE'
    end
  end
end