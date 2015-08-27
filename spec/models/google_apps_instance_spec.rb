require 'rails_helper'

RSpec.describe GoogleAppsInstance, :vcr, type: :model do
  let(:google_apps_instance){ build :staging_google_apps_instance }

  describe '.register' do
    context 'when acting properly' do
      subject{ lambda{ google_apps_instance.register('register@vmwdev.com', 'Great', 'Name') } }
      after{ google_apps_instance.unregister('register@vmwdev.com') }
      it{ is_expected.to_not raise_error }
    end

    context 'when acting inproperly' do
      subject{ lambda{ google_apps_instance.register('@foo', '', '') } }
      it{ is_expected.to raise_error(Faraday::ClientError) }
    end
  end

  describe '.unregister' do
    before{ google_apps_instance.register('unregister@vmwdev.com', 'Great', 'Name') }
    subject{ lambda{ google_apps_instance.unregister('unregister@vmwdev.com') } }
    it{ is_expected.to_not raise_error }
  end

  describe 'is idempotent' do
    describe '.register' do
      let(:register!){ lambda{ google_apps_instance.register('register_idempotent@vmwdev.com', 'Great', 'Name') } }
      before{ register! }
      subject{ register! }
      after{ google_apps_instance.unregister('register_idempotent@vmwdev.com') }
      it{ is_expected.to_not raise_error }
    end
  end
end