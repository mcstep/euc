require 'rails_helper'

RSpec.describe 'Domains UI', type: :feature do
  subject{ page }
  before{ Domain.delete_all }
  before{ create_cookie 'user_id', create(:root).id }

  describe 'index' do
    let!(:domains){ create_list :domain, 5 }
    before{ visit '/domains' }

    it{ is_expected.to have_text '5 domains found' }
    it{ is_expected.to have_text domains[2].name }
  end

  describe 'toggle' do
    let!(:domain){ create :domain }

    context 'when enabled' do
      before{ visit '/domains' }

      it{ is_expected.to have_css ".btn-success.active[href='/domains/#{domain.id}/toggle']" }

      it 'toggles' do
        click_on 'OFF'
        expect(domain.reload.status).to eq :inactive
      end
    end

    context 'when disabled' do
      before{ domain.update_attribute(:status, :inactive) }
      before{ visit '/domains' }

      it{ is_expected.to have_css ".btn-danger.active[href='/domains/#{domain.id}/toggle']" }

      it 'toggles' do
        click_on 'ON'
        expect(domain.reload.status).to eq :active
      end
    end
  end

  describe 'delete' do
    before do
      create :domain
      visit '/domains'
      click_on 'Delete'
    end

    it 'clears' do
      expect(Domain.count).to eq 0
    end
  end

  describe 'add' do
    before do
      create(:profile, name: 'Default')
      visit '/domains'
      fill_in 'Domain name...', with: 'test.com'
      click_on 'Add'
    end

    it 'creates' do
      is_expected.to have_text 'test.com'
      expect(Domain.first.name).to eq 'test.com'
    end
  end
end