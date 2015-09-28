require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:profile){ create(:profile) }

  describe '.directory_groups' do
    subject{ profile.directory_groups }
    it { expect{subject}.to_not raise_error }
  end
end