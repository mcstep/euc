require 'rails_helper'

RSpec.describe 'Modals', :js, type: :feature do
  subject{ page }
  let(:root){ create(:root) }
  before{ create_cookie 'user_id', root.id }

  describe 'profile' do
    before do
      visit '/'
      first('a[data-target="#avatar-modal"]').click
    end

    it do
      within('#avatar-modal') do
        is_expected.to have_text 'PROFILE'
      end
    end
  end
end