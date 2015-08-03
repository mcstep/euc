require 'rails_helper'

RSpec.describe ProvisionerWorker, type: :model do
  describe '.wait_until' do
    before do
      class ProvisionerSpecWorker < ProvisionerWorker
        def self.name
          'TestWorker'
        end

        def test
          @user_integration = OpenStruct.new(id: 1)
          wait_until(false){}
        end
      end

      ProvisionerSpecWorker.new.test
    end

    after do
      Object.send(:remove_const, :ProvisionerSpecWorker)
    end

    it 'reenqueus' do
      expect(ProvisionerSpecWorker).to have(1).jobs
    end

    it 'stores the method name' do
      expect(ProvisionerSpecWorker.jobs.last['args']).to eq [1, 'test']
    end
  end
end