require 'rails_helper'

RSpec.describe ProvisionerWorker, type: :model do
  describe '.wait_until' do
    before do
      class ProvisionerSpecWorker < ProvisionerWorker
        def self.name
          'TestWorker'
        end

        def perform
          @user_integration = OpenStruct.new(id: 1)
          wait_until(false){}
        end
      end

      ProvisionerSpecWorker.new.perform
    end

    after do
      Object.send(:remove_const, :ProvisionerSpecWorker)
    end

    it 'reenqueus' do
      expect(ProvisionerSpecWorker).to have(1).jobs
    end
  end
end