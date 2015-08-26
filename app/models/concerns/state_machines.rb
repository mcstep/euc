module StateMachines
  extend ActiveSupport::Concern

  class Machine < MicroMachine
    attr_accessor :normalizer

    def initialize(instance, field, &block)
      super instance.send(field)

      @normalizer = block
      @instance   = instance
      @field      = field

      unless instance.deleted_at?
        self.when :enable,
          revoked:        :provisioning,
          disabled:       :provisioning,
          available:      :provisioning

        self.when :allow,
          disabled:       :available

        if instance.new_record?
          self.when :disable, provisioning: :disabled, provisioned: :disabled
        else
          self.when :disable, provisioned: :revoking
        end
      end

      self.when :complete_application,
        provisioning:   :provisioned,
        revoking:       :revoked,
        deprovisioning: :disabled

      self.when :cleanup,
        revoking:       :deprovisioning

      self.on(:any) { normalize_and_store! }
    end

    def method_missing(name, *args)
      trigger!(name)
    end

    def complete_application
      if @instance.deleted_at? && @instance.send(@field) == :revoking
        trigger!(:cleanup)
      else
        trigger!(:complete_application)
      end
    end

    def normalize_and_store!
      @state = @normalizer.call(@state) if @normalizer.present?
      @instance.send :"#{@field}=", @state
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
      if user && !user.airwatch_eula_accept_date && state == :provisioning
        :not_approved
      else
        state
      end
    end

    m.when :approve,
      not_approved:   :provisioning

    if new_record?
      m.when :disable, provisioning: :disabled, provisioned: :disabled, not_approved: :disabled
    else
      m.when :disable, provisioned: :revoking, not_approved: :disabled
    end

    machines[:airwatch] = m
  end

  Integration::SERVICES.each do |service|
    next if service == 'airwatch'

    define_method service do
      machines[service] ||= Machine.new(self, :"#{service}_status")
    end
  end
end