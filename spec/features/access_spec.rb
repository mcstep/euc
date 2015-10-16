require 'rails_helper'

RSpec.describe 'Access', :vcr, type: :feature do
  subject{ page }
  before{ create_cookie 'user_id', user.id }

  describe 'New invite visibility' do
    before{ visit '/' }

    context 'when user is root with no invitations left' do
      let(:user){ create(:root, total_invitations: 0) }
      it{ is_expected.to have_link('Invite New User') }
      it{ is_expected.to have_link('Send Invitation') }
    end

    context 'when user is admin with no invitations left' do
      let(:user){ create(:admin, total_invitations: 0) }
      it{ is_expected.to_not have_link('Invite New User') }
      it{ is_expected.to_not have_link('Send Invitation') }
    end
  end

  describe 'Reporting visibility' do
    before{ visit '/' }

    context 'when user is root with can_see_reports = false' do
      let(:user){ create(:root, can_see_reports: false) }
      it{ is_expected.to_not have_link('Reporting') }
    end

    context 'when user is basic with can_see_reports = true' do
      let(:user){ create(:user, can_see_reports: true) }
      it{ is_expected.to have_link('Reporting') }
    end
  end
end