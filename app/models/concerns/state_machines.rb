module StateMachines
  extend ActiveSupport::Concern

  included do
    before_validation { Integration::SERVICES.each{|s| send(s).normalize_and_store!} }
    before_validation { integration.disabled_services.each{|s| send("#{s}_status=", :deprovisioned)} if integration }
    after_save        { @machines = {} }
  end

  Integration::SERVICES.each do |service|
    define_method service do
      Machine.new(self, service)
    end
  end

  def airwatch
    AirwatchMachine.new(self, :airwatch)
  end
end