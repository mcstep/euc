require 'rails_helper'

RSpec.describe GoogleAppsInstance, :vcr, type: :model do
  let(:google_apps_instance){ build :real_google_apps_instance }

  describe '.register' do
    subject{ lambda{ google_apps_instance.register('test@vmwdev.com', 'Great', 'Name') } }
    after{ google_apps_instance.unregister('test@vmwdev.com') }
    it{ is_expected.to_not raise_error }
  end

  describe '.unregister' do
    before{ google_apps_instance.register('test@vmwdev.com', 'Great', 'Name') }
    subject{ lambda{ google_apps_instance.unregister('test@vmwdev.com') } }
    it{ is_expected.to_not raise_error }
  end
end