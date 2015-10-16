require 'rails_helper'

RSpec.describe 'Authentication UI', :vcr, type: :feature do
  subject{ page }

  describe 'redirection' do
    it 'sends to login page' do
      visit '/'
      expect(current_path).to eq '/session/new'
    end

    context 'when authenticated' do
      before{ create_cookie 'user_id', create(:root).id }

      it 'allows authenticated requests' do
        visit '/'
        expect(current_path).to eq '/'
      end
    end
  end

  describe 'form', :vcr do
    before do
      create :full_user, email: 'test@test.com'
      visit '/session/new'

      within('#login-modal') do
        fill_in 'Username', with: 'test@test.com'
        fill_in 'Password', with: 'DevPassword123'

        click_on 'Login'
      end
    end

    it('works') { is_expected.to have_text 'Logged in!' }
  end
end