require 'rails_helper'

RSpec.describe ProfileIntegration, type: :model do
  let(:profile_integration){ create(:profile_integration, airwatch_default_status: :available) }

  describe '.to_user_integration' do
    subject{ profile_integration.to_user_integration }
    it { expect{subject}.to_not raise_error }
  end
end