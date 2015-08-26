require 'rails_helper'

RSpec.describe AirwatchTemplate, :vcr, type: :model do
  let(:airwatch_instance){ build :staging_airwatch_instance }
  let(:user_integration) do
    ui = build :airwatch_user_integration
    ui.user = build :user, company_name: 'ZOMG Company 2'
    ui.integration.domain = 'spec65.com'
    ui.integration.airwatch_instance = airwatch_instance
    ui
  end
  let(:airwatch_template){ AirwatchTemplate.produce(user_integration) }

  describe '.produce' do
    it{ expect(airwatch_template.data).to include('name' => 'ZOMG Company 2') }
  end

  describe '.to_h' do
    subject{ airwatch_template.to_h }
    it{ is_expected.to include("ZOMG Company 2"=>1974) }
  end
end