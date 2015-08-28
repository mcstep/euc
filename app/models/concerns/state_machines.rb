module StateMachines
  extend ActiveSupport::Concern

  included do
    before_validation { Integration::SERVICES.each{|s| send(s).normalize_and_store!} }
    before_validation { integration.disabled_services.each{|s| send("#{s}_status=", :deprovisioned)} if integration }
    after_save        { @machines = {} }
  end

  def machines
    @machines ||= {}
  end

  Integration::SERVICES.each do |service|
    define_method service do
      machines[service] ||= Machine.new(self, service)
    end
  end

  def airwatch
    machines[:airwatch] ||= AirwatchMachine.new(self, :airwatch)
  end
end