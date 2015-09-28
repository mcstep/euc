require 'rails_helper'

RSpec.describe HorizonInstance, type: :model do
  let(:horizon_instance){ create(:horizon_instance) }

  describe '.title' do
    subject{ horizon_instance.title }
    it { expect{subject}.to_not raise_error }
  end
end