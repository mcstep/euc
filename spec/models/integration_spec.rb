require 'rails_helper'

RSpec.describe Integration, type: :model do
  let(:integration){ create(:integration) }

  describe '.enabled_services' do
    subject{ integration.enabled_services }
    it { expect{subject}.to_not raise_error }
  end

  describe '.disabled_services' do
    subject{ integration.disabled_services }
    it { expect{subject}.to_not raise_error }
  end
end
