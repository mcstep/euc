require 'rails_helper'

RSpec.fdescribe Office365Instance, :vcr, type: :model do
  let(:blue_jeans_instance){ create :staging_blue_jeans_instance }

  describe '.token' do
    subject{ raise blue_jeans_instance.token.inspect }

    it{ is_expected.to eq nil }
  end
end