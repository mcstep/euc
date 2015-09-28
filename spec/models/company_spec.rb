require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create(:company) }

  describe '.potential_seats_invited_by' do
    subject{ company.potential_seats_invited_by(create :user) }
    it { expect{subject}.to_not raise_error }
  end
end