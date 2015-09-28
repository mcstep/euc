require 'rails_helper'

RSpec.describe DirectoryProlongation, type: :model do
  let(:user_integration){ create(:user_integration) }

  describe 'validation' do
    subject{ DirectoryProlongation.new(user_integration: user_integration) }
    it{ is_expected.to be_valid }
  end

  describe 'creation' do
    subject{ DirectoryProlongation.create!(user_integration: user_integration) }
    it{ expect{subject}.to change{user_integration.directory_expiration_date} }
  end
end