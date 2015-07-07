module UserIntegration::StateMachines
  extend ActiveSupport::Concern

  class Machine < MicroMachine
    attr_accessor :normalizer

    def initialize(instance, field, &block)
      super instance.send(field)

      @normalizer = block
      @instance   = instance
      @field      = field

      self.when :enable, revoked: :not_provisioned, disabled: :not_provisioned
      self.when :provision, not_provisioned: :provisioned
      self.when :deprovision, provisioned: :disabled

      if instance.new_record?
        self.when :disable, not_provisioned: :disabled, provisioned: :disabled
      else
        self.when :disable, provisioned: :revoked
      end

      self.on(:any) { normalize_and_store! }
    end

    def normalize_and_store!
      @state = @normalizer.call(@state) if @normalizer.present?
      @instance.send :"#{@field}=", @state
    end

    def method_missing(name, *args)
      trigger!(name)
    end
  end

  included do
    before_validation { airwatch.normalize_and_store! }
    before_validation { integration.disabled_services.each{|s| send("#{s}_status=", :disabled)} if integration }
    after_save        { @machines = {} }
  end

  def machines
    @machines ||= {}
  end

  def airwatch
    return machines[:airwatch] if machines[:airwatch]

    m = Machine.new(self, :airwatch_status) do |state|
      if user && !user.airwatch_eula_accept_date && state == :not_provisioned
        :not_approved
      else
        state
      end
    end

    m.when :approve, not_approved: :not_provisioned

    machines[:airwatch] = m
  end

  Integration::SERVICES.each do |service|
    next if service == 'airwatch'

    define_method service do
      machines[service] ||= Machine.new(self, :"#{service}_status")
    end
  end
end