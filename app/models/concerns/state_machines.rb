module StateMachines
  extend ActiveSupport::Concern

  class Machine < MicroMachine
    attr_accessor :normalizer

    def initialize(instance, service, &block)
      @normalizer = block
      @instance   = instance
      @field      = "#{service}_status"

      super instance.send(@field)

      unless instance.deleted_at?
        unless instance.send("prohibit_#{service}")
          self.when :toggle,
            revoked:        :provisioning,
            deprovisioned:  :provisioning,
            provisioned:    :revoking,
            not_approved:   :deprovisioned
        end

        self.when :approve,
          not_approved:   :provisioning

        if instance.new_record?
          self.when :prohibit,
            deprovisioned:  :deprovisioned,
            provisioning:   :deprovisioned,
            provisioned:    :deprovisioned,
            not_approved:   :deprovisioned
        else
          self.when :prohibit,
            deprovisioned:  :deprovisioned,
            provisioned:    :revoking,
            not_approved:   :deprovisioned
        end
      end

      self.when :complete_application,
        provisioning:   :provisioned,
        revoking:       :revoked,
        deprovisioning: :deprovisioned

      self.when :deprovision,
        not_approved:   :deprovisioned,
        deprovisioned:  :deprovisioned,
        provisioned:    :revoking,
        revoked:        :deprovisioning,
        revoking:       :deprovisioning

      self.on(:any) { normalize_and_store! }
    end

    def method_missing(name, *args)
      trigger!(name)
    end

    def complete_application
      if @instance.deleted_at? && @instance.send(@field) == :revoking
        trigger!(:deprovision)
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
    before_validation { Integration::SERVICES.each{|s| send(s).normalize_and_store!} }
    before_validation { integration.disabled_services.each{|s| send("#{s}_status=", :deprovisioned)} if integration }
    after_save        { @machines = {} }
  end

  def machines
    @machines ||= {}
  end

  def airwatch
    return machines[:airwatch] if machines[:airwatch]

    m = Machine.new(self, :airwatch) do |state|
      if user && !user.airwatch_eula_accept_date && state == :provisioning
        :not_approved
      else
        state
      end
    end

    machines[:airwatch] = m
  end

  Integration::SERVICES.each do |service|
    next if service == 'airwatch'

    define_method service do
      machines[service] ||= Machine.new(self, service)
    end
  end
end