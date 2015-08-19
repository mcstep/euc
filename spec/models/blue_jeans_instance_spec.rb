require 'rails_helper'

RSpec.describe BlueJeansInstance, :vcr, type: :model do
  let(:blue_jeans_instance){ create :staging_blue_jeans_instance }

  describe '.token' do
    subject{ blue_jeans_instance.token }

    it{ expect(subject.length).to eq 32 }
  end
end