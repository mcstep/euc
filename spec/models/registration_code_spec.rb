require 'rails_helper'

RSpec.describe RegistrationCode, type: :model do
  let(:registration_code){ create(:registration_code) }

  describe '#actual' do
    subject{ RegistrationCode.actual }
    it { expect{subject}.to_not raise_error }
  end

  describe 'saving' do
    subject{ registration_code }
    it { expect{subject}.to_not raise_error }
  end
end