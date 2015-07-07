require 'rails_helper'

RSpec.describe 'modals', :js, type: :feature do
  subject{ page }
  let(:root){ create(:root) }
  before{ create_cookie 'user_id', root.id }

  describe 'profile' do
    before do
      visit '/'
      click_link 'Edit Profile'
    end

    it do
      within('#avatar-modal') do
        is_expected.to have_text 'PROFILE'
      end
    end
  end
end