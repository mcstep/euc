require 'rails_helper'

RSpec.describe 'Modals', :js, type: :feature do
  subject{ page }
  before{ create_cookie 'user_id', user.id }

  describe 'New invite visibility' do
    before{ visit '/' }

    context 'when user is root with no invitations left' do
      let(:user){ create(:root, total_invitations: 0) }
      it{ is_expected.to have_link('Invite user') }
      it{ is_expected.to have_link('Send Invitation') }
    end

    context 'when user is admin with no invitations left' do
      let(:user){ create(:admin, total_invitations: 0) }
      it{ is_expected.to_not have_link('Invite user') }
      it{ is_expected.to_not have_link('Send Invitation') }
    end
  end
end